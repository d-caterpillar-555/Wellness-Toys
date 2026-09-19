// desk: the concierge.
//
// A scripted conversation, not a language model, and it says so. The script is
// the navigation: the visitor picks a concern, the desk answers with the real
// objects from the shelf the page published, and free text falls through to a
// search of the same shelf. Every answer is also a link, so nothing is trapped
// in the transcript.
//
// One rule the script keeps: it does not give clinical advice. Where a question
// is medical it says so and points at the library.
export default class Desk {
  constructor(root = document) {
    this.root = root;
    this.transcript = root.querySelector("[data-desk-transcript]");
    this.replies = root.querySelector("[data-desk-replies]");
    this.form = root.querySelector("[data-desk-form]");
    const source = root.querySelector("[data-desk-shelf]");
    if (!this.transcript || !this.replies || !source) return;

    this.shelf = JSON.parse(source.textContent);
    this.csrf = document.querySelector('meta[name="csrf-token"]')?.content;
    this.state = "opening";

    this.say("desk", "Good evening. I am the desk: a script, not a person, and not a clinician. I can show you what we stock, what we publish, or where an order has got to.");
    this.ask(this.openingReplies());

    this.form?.addEventListener("submit", (event) => {
      event.preventDefault();
      const input = this.form.querySelector("input[type=search]");
      const query = input.value.trim();
      if (query === "") return;
      input.value = "";
      this.say("you", query);
      this.search(query);
    });
  }

  // --- what the desk can say ----------------------------------------------

  openingReplies() {
    return [
      { label: "Something for me", next: () => this.byDepartment("What are you looking for? Here is the shelf, by department.") },
      { label: "Something for a partner", next: () => this.sayTalk("That is a good reason to be careful. Everything here is documented before it is described, so you can check the materials before you choose.", () => this.byDepartment("Tell me which department to show.")) },
      { label: "Just reading", next: () => this.library() },
      { label: "An order question", next: () => this.orders() }
    ];
  }

  byDepartment(prompt) {
    this.say("desk", prompt);
    const departments = [ ...new Set(this.shelf.map((item) => item.department)) ];
    this.ask(departments.map((department) => ({
      label: department,
      next: () => this.showDepartment(department)
    })).concat([ { label: "Everything", next: () => this.showAll() } ]));
  }

  showDepartment(department) {
    const items = this.shelf.filter((item) => item.department === department);
    this.say("desk", `${department}: ${items.length} ${items.length === 1 ? "object" : "objects"}. Each one is documented before it is described.`);
    for (const item of items) this.offer(item);
    this.ask([
      { label: "Another department", next: () => this.byDepartment("Which department?") },
      { label: "Everything", next: () => this.showAll() }
    ]);
  }

  showAll() {
    this.say("desk", `The whole shelf: ${this.shelf.length} objects. I will keep it short - the line under each one is what the shop says it is for.`);
    for (const item of this.shelf) this.offer(item);
    this.ask(this.openingReplies());
  }

  library() {
    this.say("desk", "The library is the publishing side: guides and explainers, written by named people, with the sources printed on every piece. It is not a substitute for a clinician, and it says so where that matters.");
    this.ask([
      { label: "Open the library", next: () => this.link("The library", this.dataset("libraryUrl")) },
      { label: "Back", next: () => this.ask(this.openingReplies()) }
    ]);
  }

  orders() {
    this.say("desk", "Orders are handled by support, and shipping is plain: no product name on the outside and a billing line that names the company and nothing else. If you have a token for an order, its status page shows where it has got to.");
    this.ask([
      { label: "Shipping and returns", next: () => this.link("Shipping", this.dataset("shippingUrl")) },
      { label: "Privacy", next: () => this.link("Privacy", this.dataset("privacyUrl")) },
      { label: "Back", next: () => this.ask(this.openingReplies()) }
    ]);
  }

  sayTalk(text, next) {
    this.say("desk", text);
    next();
  }

  search(query) {
    const needle = query.toLowerCase();
    const hits = this.shelf.filter((item) =>
      `${item.name} ${item.line} ${item.department}`.toLowerCase().includes(needle)
    );

    if (hits.length === 0) {
      this.say("desk", "I do not know that one. I only know what is on the shelf, and I would rather say so than guess. Here is everything, or the library if the question is not about an object.");
      this.ask([
        { label: "Show the shelf", next: () => this.showAll() },
        { label: "The library", next: () => this.library() }
      ]);
      return;
    }

    this.say("desk", `${hits.length} ${hits.length === 1 ? "object matches" : "objects match"} that.`);
    for (const item of hits.slice(0, 6)) this.offer(item);
    this.ask(this.openingReplies());
  }

  // --- how it looks on screen ---------------------------------------------

  say(who, text) {
    const message = document.createElement("div");
    message.className = `desk-turn desk-turn--${who}`;

    const body = document.createElement("p");
    body.className = "desk-turn__body";
    body.textContent = text;
    message.appendChild(body);

    this.transcript.appendChild(message);
    this.scroll();
  }

  offer(item) {
    const card = document.createElement("article");
    card.className = "desk-offer";

    const name = document.createElement("h3");
    name.className = "desk-offer__name";
    const link = document.createElement("a");
    link.href = item.url;
    link.textContent = item.name;
    name.appendChild(link);
    card.appendChild(name);

    const meta = document.createElement("p");
    meta.className = "desk-offer__meta";
    meta.textContent = `${item.department} - ${item.price}${item.editions.length > 1 ? ` - ${item.editions.length} editions` : ""}`;
    card.appendChild(meta);

    const line = document.createElement("p");
    line.className = "desk-offer__line";
    line.textContent = item.line.length > 160 ? `${item.line.slice(0, 157)}...` : item.line;
    card.appendChild(line);

    if (item.variant_id) {
      const actions = document.createElement("p");
      actions.className = "desk-offer__actions";
      const button = document.createElement("button");
      button.type = "button";
      button.className = "desk-offer__button";
      button.textContent = "Bring it to the desk";
      button.addEventListener("click", () => this.add(item, button));
      actions.appendChild(button);
      card.appendChild(actions);
    }

    this.transcript.appendChild(card);
    this.scroll();
  }

  async add(item, button) {
    button.disabled = true;
    button.textContent = "Bringing it ...";

    const body = new FormData();
    body.append("variant_id", item.variant_id);
    body.append("quantity", "1");

    try {
      const response = await fetch(item.cart_url, {
        method: "POST",
        headers: { "X-CSRF-Token": this.csrf, "Accept": "text/html" },
        body,
        credentials: "same-origin"
      });

      if (response.ok || response.redirected) {
        button.textContent = "In the basket";
        this.say("desk", `${item.name} is in the basket. The basket itself is the shop's own page - it is the one room this desk does not dress.`);
      } else {
        button.disabled = false;
        button.textContent = "Try again";
        this.say("desk", "The shop refused that, so nothing was added. Try again, or use the object's own page.");
      }
    } catch (error) {
      button.disabled = false;
      button.textContent = "Try again";
      this.say("desk", "I could not reach the shop, so nothing was added.");
    }
  }

  ask(options) {
    this.replies.replaceChildren();
    for (const option of options) {
      const button = document.createElement("button");
      button.type = "button";
      button.className = "desk-reply";
      button.textContent = option.label;
      button.addEventListener("click", () => {
        this.say("you", option.label);
        option.next();
      });
      this.replies.appendChild(button);
    }
    this.scroll();
  }

  link(label, href) {
    const row = document.createElement("p");
    row.className = "desk-turn desk-turn--desk";
    const anchor = document.createElement("a");
    anchor.href = href;
    anchor.textContent = label;
    anchor.className = "desk-link";
    row.appendChild(anchor);
    this.transcript.appendChild(row);
    this.scroll();
  }

  dataset(name) {
    return this.root.querySelector("[data-desk]")?.dataset[name] || "/";
  }

  scroll() {
    this.transcript.scrollTop = this.transcript.scrollHeight;
  }
}

new Desk();
