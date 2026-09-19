// shell: the whole shop as a machine.
//
// The prompt is real: paths resolve against a tree the server published
// (a catalogue directory, a library directory, and the reference pages), and
// `add` posts to the same cart the rest of the site uses. Everything printed
// here is written with textContent, never as markup, because a product name is
// data and this is a terminal.
//
// Commands: help, ls, cat, find, add, open, clear.
export default class Shell {
  constructor(root = document) {
    this.root = root;
    this.screen = root.querySelector("[data-shell-screen]");
    this.input = root.querySelector("[data-shell-input]");
    const source = root.querySelector("[data-shell-tree]");
    if (!this.screen || !this.input || !source) return;

    this.tree = JSON.parse(source.textContent);
    this.cwd = [];
    this.history = [];
    this.historyIndex = -1;
    this.csrf = document.querySelector('meta[name="csrf-token"]')?.content;

    this.print("wellness-toys shell 1.0 - the catalogue, the library and the reference pages.");
    this.print("type `help` for the commands, or `ls` to look around.", "muted");

    const focus = root.querySelector("[data-shell]")?.dataset.focus;
    if (focus) this.run(`cat ${focus}`);
    else this.print("");

    this.input.addEventListener("keydown", (event) => this.onKey(event));
    root.addEventListener("click", (event) => {
      if (!event.target.closest("a")) this.input.focus();
    });
    this.input.focus();
  }

  // --- input --------------------------------------------------------------

  onKey(event) {
    if (event.key === "Enter") {
      const line = this.input.value;
      this.input.value = "";
      if (line.trim() !== "") {
        this.history.push(line);
        this.historyIndex = this.history.length;
      }
      this.run(line);
    } else if (event.key === "ArrowUp") {
      event.preventDefault();
      this.recall(-1);
    } else if (event.key === "ArrowDown") {
      event.preventDefault();
      this.recall(1);
    } else if (event.key === "Tab") {
      event.preventDefault();
      this.complete();
    } else if (event.key === "l" && event.ctrlKey) {
      event.preventDefault();
      this.clear();
    }
  }

  recall(direction) {
    if (this.history.length === 0) return;
    this.historyIndex = Math.max(0, Math.min(this.history.length, this.historyIndex + direction));
    this.input.value = this.history[this.historyIndex] || "";
    this.input.setSelectionRange(this.input.value.length, this.input.value.length);
  }

  complete() {
    const value = this.input.value;
    const [ command, ...rest ] = value.split(" ");
    const names = this.commands().map((entry) => entry[0]);

    if (rest.length === 0 && !value.includes(" ")) {
      const match = names.filter((name) => name.startsWith(command));
      if (match.length === 1) this.input.value = `${match[0]} `;
      else if (match.length > 1) this.print(match.join("  "), "muted");
      return;
    }

    const partial = rest.join(" ");
    const candidates = (this.cwdNode().children || [])
      .map((child) => child.name)
      .filter((name) => name.startsWith(partial));
    if (candidates.length === 1) {
      this.input.value = `${command} ${candidates[0]}`;
    } else if (candidates.length > 1) {
      this.print(candidates.join("  "), "muted");
    }
  }

  // --- commands -----------------------------------------------------------

  commands() {
    return [
      [ "help", "this list" ],
      [ "ls [path]", "list a directory" ],
      [ "cat <path>", "print an object, an article or a page" ],
      [ "find <term>", "search the catalogue and the library" ],
      [ "add <path>", "put the first edition of an object in the basket" ],
      [ "open <path>", "leave the shell for the page itself" ],
      [ "cd [path]", "change directory" ],
      [ "pwd", "where you are" ],
      [ "clear", "clear the screen" ]
    ];
  }

  run(line) {
    const trimmed = line.trim();
    if (trimmed === "") return;

    this.echo(trimmed);
    const [ command, ...args ] = trimmed.split(/\s+/);
    const argument = args.join(" ");

    switch (command) {
      case "help":
        for (const [ name, description ] of this.commands()) {
          this.print(`  ${name.padEnd(14)} ${description}`, "muted");
        }
        break;
      case "ls":
        this.list(argument);
        break;
      case "cat":
        this.cat(argument);
        break;
      case "find":
        this.find(argument);
        break;
      case "add":
        this.add(argument);
        break;
      case "open":
        this.open(argument);
        break;
      case "clear":
        this.clear();
        break;
      case "pwd":
        this.print(`/${this.cwd.join("/")}`);
        break;
      case "cd":
        this.change(argument);
        break;
      default:
        this.print(`unknown command: ${command}. Try \`help\`.`, "error");
    }

    this.print("");
  }

  list(argument) {
    if (argument) {
      const found = this.resolve(argument);
      if (found.error) return this.print(found.error, "error");
      if (!found.node.children) return this.print(`${argument} is not a directory`, "error");
      return this.printChildren(found.node);
    }

    const current = this.cwdNode();
    if (!current.children) return this.print("nothing here", "muted");
    this.printChildren(current);
  }

  printChildren(node) {
    const names = node.children.map((child) => (child.children ? `${child.name}/` : child.name));
    if (names.length === 0) return this.print("(empty)", "muted");
    this.print(names.join("  "));
  }

  cat(argument) {
    if (!argument) return this.print("cat what? Try `ls`.", "error");

    const found = this.resolve(argument);
    if (found.error) return this.print(found.error, "error");

    const node = found.node;
    if (node.children) return this.print(`${argument} is a directory`, "error");

    if (node.title) this.print(node.title, "strong");
    if (node.sku) this.print(`${node.sku} - ${node.price}`, "accent");
    for (const line of node.lines || []) this.print(`  ${line}`, "muted");
    if (node.description) {
      this.print("");
      this.print(node.description);
    }
    if (node.type === "object") {
      this.print("");
      if (node.variants?.length > 1) {
        this.print(`  editions: ${node.variants.map((variant) => `${variant.name} ${variant.price}`).join(", ")}`, "muted");
      }
      this.print(`  add ${this.pathOf(node)}`, "muted");
    }
    if (node.url) {
      this.print(`  open ${this.pathOf(node)}`, "muted");
    }
  }

  find(term) {
    if (!term) return this.print("find what?", "error");
    const needle = term.toLowerCase();
    const hits = this.walk(this.tree).filter((node) =>
      (node.title || node.name).toLowerCase().includes(needle)
    );

    if (hits.length === 0) return this.print(`nothing matches \`${term}\``, "muted");

    for (const node of hits.slice(0, 12)) {
      const path = this.pathOf(node);
      this.print(`  ${path}${node.title ? `  - ${node.title}` : ""}`);
    }
    if (hits.length > 12) this.print(`  ... and ${hits.length - 12} more`, "muted");
  }

  async add(argument) {
    if (!argument) return this.print("add what? Try `ls catalogue`.", "error");

    const found = this.resolve(argument);
    if (found.error) return this.print(found.error, "error");

    const node = found.node;
    if (node.type !== "object") return this.print(`${argument} is not an object`, "error");
    if (!node.variant_id) return this.print(`no edition of ${node.title} is available right now`, "error");

    const body = new FormData();
    body.append("variant_id", node.variant_id);
    body.append("quantity", "1");

    this.print(`adding ${node.title} ...`, "muted");

    try {
      const response = await fetch(node.cart_url, {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.csrf,
          "Accept": "text/html"
        },
        body,
        credentials: "same-origin",
        redirect: "follow"
      });

      if (response.ok || response.redirected) {
        this.print(`${node.title} is in the basket.`, "accent");
        this.link("open the basket", node.cart_url);
      } else {
        this.print(`the shop refused that (${response.status}). Nothing was added.`, "error");
      }
    } catch (error) {
      this.print("could not reach the shop. Nothing was added.", "error");
    }
  }

  open(argument) {
    if (!argument) return this.print("open what?", "error");
    if (argument.startsWith("http") || argument.startsWith("/")) {
      window.location.assign(argument);
      return;
    }

    const found = this.resolve(argument);
    if (found.error) return this.print(found.error, "error");
    if (!found.node.url) return this.print(`${argument} has no page of its own`, "error");
    window.location.assign(found.node.url);
  }

  change(argument) {
    if (!argument || argument === "/") {
      this.cwd = [];
      return;
    }
    const found = this.resolve(argument);
    if (found.error) return this.print(found.error, "error");
    if (!found.node.children) return this.print(`${argument} is not a directory`, "error");
    this.cwd = this.partsOf(found.node);
  }

  // --- tree helpers -------------------------------------------------------

  resolve(raw) {
    const parts = [];
    const segments = raw.split("/").filter((segment) => segment !== "" && segment !== ".");

    if (!raw.startsWith("/")) parts.push(...this.cwd);

    for (const segment of segments) {
      if (segment === "..") parts.pop();
      else parts.push(segment);
    }

    let node = this.tree;
    for (const part of parts) {
      const next = (node.children || []).find((child) => child.name === part);
      if (!next) {
        // Not where the prompt is standing. If exactly one node in the tree has
        // this name, that is what was meant; if several do, ask for the path.
        const matches = this.walk(this.tree).filter((candidate) => candidate.name === parts[parts.length - 1]);
        if (matches.length === 1) return { node: matches[0], parts: matches[0].path };
        if (matches.length > 1) return { error: `\`${raw}\` is ambiguous - ${matches.length} nodes have that name. Try \`find ${parts[parts.length - 1]}\`.` };
        return { error: `no such path: ${raw}` };
      }
      node = next;
    }
    return { node, parts };
  }

  cwdNode() {
    let node = this.tree;
    for (const part of this.cwd) {
      node = (node.children || []).find((child) => child.name === part) || node;
    }
    return node;
  }

  walk(node, path = [], found = []) {
    for (const child of node.children || []) {
      const childPath = [ ...path, child.name ];
      child.path = childPath;
      found.push(child);
      this.walk(child, childPath, found);
    }
    return found;
  }

  pathOf(node) {
    return `/${(node.path || [ node.name ]).join("/")}`;
  }

  partsOf(node) {
    return node.path || [ node.name ];
  }

  // --- screen -------------------------------------------------------------

  echo(line) {
    this.line(`$ ${line}`, "echo");
  }

  print(text = "", kind = "") {
    this.line(text, kind);
  }

  link(label, href) {
    const row = document.createElement("div");
    row.className = "shell-line shell-line--muted";
    const anchor = document.createElement("a");
    anchor.href = href;
    anchor.textContent = `  ${label}`;
    anchor.className = "shell-link";
    row.appendChild(anchor);
    this.screen.appendChild(row);
    this.scroll();
  }

  line(text, kind) {
    const row = document.createElement("div");
    row.className = kind ? `shell-line shell-line--${kind}` : "shell-line";
    row.textContent = text;
    this.screen.appendChild(row);
    this.scroll();
  }

  clear() {
    this.screen.replaceChildren();
  }

  scroll() {
    this.screen.scrollTop = this.screen.scrollHeight;
  }
}

new Shell();
