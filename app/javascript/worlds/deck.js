// deck: the console.
//
// The table is real HTML, so the catalogue is readable and linkable without
// JavaScript. This module adds what a console is for: filtering and sorting
// without a round trip, a record that opens in a side sheet, the basket from
// the sheet, and keys for all of it.
//
//   /        focus the filter
//   j / k    move down / up the rows
//   enter    open the selected record
//   escape   close the sheet or clear the filter
//   cmd/ctrl + k   jump to the filter from anywhere
export default class Deck {
  constructor(root = document) {
    this.root = root;
    this.table = root.querySelector("[data-deck-table]");
    this.filter = root.querySelector("[data-deck-filter]");
    this.count = root.querySelector("[data-deck-count]");
    this.sheet = root.querySelector("[data-deck-sheet]");
    this.sheetBody = root.querySelector("[data-deck-sheet-body]");
    const source = root.querySelector("[data-deck-records]");
    if (!this.table || !source) return;

    this.records = JSON.parse(source.textContent);
    this.csrf = document.querySelector('meta[name="csrf-token"]')?.content;
    this.rows = Array.from(this.table.querySelectorAll("[data-deck-row]"));
    this.selected = -1;

    this.filter?.addEventListener("input", () => this.applyFilter());
    for (const header of root.querySelectorAll("[data-deck-sort]")) {
      header.addEventListener("click", () => this.sort(header.dataset.deckSort));
    }
    for (const row of this.rows) {
      row.addEventListener("click", (event) => {
        if (event.target.closest("a")) return;
        this.select(this.rows.indexOf(row));
        this.open(row.dataset.slug);
      });
    }

    document.addEventListener("keydown", (event) => this.onKey(event));
    this.sheet?.querySelector("[data-deck-sheet-close]")?.addEventListener("click", () => this.close());

    this.updateCount();
  }

  onKey(event) {
    const typing = [ "INPUT", "SELECT", "TEXTAREA" ].includes(document.activeElement?.tagName);

    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
      event.preventDefault();
      this.filter?.focus();
      return;
    }

    if (event.key === "/" && !typing) {
      event.preventDefault();
      this.filter?.focus();
      return;
    }

    if (event.key === "Escape") {
      if (this.sheet?.hidden === false && !typing) {
        this.close();
      } else if (typing) {
        this.filter.value = "";
        this.applyFilter();
        this.filter.blur();
      }
      return;
    }

    if (typing) return;

    if (event.key === "j" || event.key === "ArrowDown") {
      event.preventDefault();
      this.move(1);
    } else if (event.key === "k" || event.key === "ArrowUp") {
      event.preventDefault();
      this.move(-1);
    } else if (event.key === "Enter") {
      const row = this.rows[this.selected];
      if (row) this.open(row.dataset.slug);
    }
  }

  visibleRows() {
    return this.rows.filter((row) => !row.hidden);
  }

  move(step) {
    const visible = this.visibleRows();
    if (visible.length === 0) return;
    const current = visible.indexOf(this.rows[this.selected]);
    const next = current === -1 ? 0 : Math.min(visible.length - 1, Math.max(0, current + step));
    this.select(this.rows.indexOf(visible[next]));
    visible[next].scrollIntoView({ block: "nearest" });

    // Browsing keeps working while a record is open.
    if (this.sheet?.hidden === false) this.open(visible[next].dataset.slug);
  }

  select(index) {
    this.rows.forEach((row) => row.removeAttribute("data-selected"));
    this.selected = index;
    if (index >= 0) this.rows[index].setAttribute("data-selected", "true");
  }

  applyFilter() {
    const needle = (this.filter?.value || "").trim().toLowerCase();

    for (const row of this.rows) {
      const haystack = row.dataset.search || "";
      row.hidden = needle !== "" && !haystack.includes(needle);
    }

    this.updateCount();
    const visible = this.visibleRows();
    this.select(visible.length > 0 ? this.rows.indexOf(visible[0]) : -1);
  }

  sort(key) {
    const body = this.table.querySelector("tbody");
    const direction = this.table.dataset.sortKey === key && this.table.dataset.sortDirection === "asc" ? "desc" : "asc";
    this.table.dataset.sortKey = key;
    this.table.dataset.sortDirection = direction;

    const sorted = [ ...this.rows ].sort((a, b) => {
      const left = a.dataset[key] || "";
      const right = b.dataset[key] || "";
      const comparison = key === "price" ? Number(left) - Number(right) : left.localeCompare(right);
      return direction === "asc" ? comparison : -comparison;
    });

    for (const row of sorted) body.appendChild(row);
    this.rows = sorted;
  }

  updateCount() {
    if (!this.count) return;
    const visible = this.visibleRows().length;
    this.count.textContent = `${visible} of ${this.rows.length} objects`;
  }

  open(slug) {
    const record = this.records.find((entry) => entry.slug === slug);
    if (!record || !this.sheet || !this.sheetBody) return;

    this.sheetBody.replaceChildren();

    const title = document.createElement("h2");
    title.className = "deck-sheet__title";
    title.textContent = record.name;
    this.sheetBody.appendChild(title);

    const meta = document.createElement("p");
    meta.className = "deck-sheet__meta";
    meta.textContent = `${record.department}${record.maker ? ` - ${record.maker}` : ""} - ${record.sku} - ${record.price}`;
    this.sheetBody.appendChild(meta);

    const figures = document.createElement("dl");
    figures.className = "deck-sheet__figures";
    const pairs = [
      [ "Materials", record.materials ],
      [ "Body safe", record.body_safe ? "Yes" : "No" ],
      [ "Dimensions", record.dimensions ],
      [ "Stock", record.in_stock ? "In stock" : "Out of stock" ]
    ];
    for (const [ label, value ] of pairs) {
      if (!value) continue;
      const row = document.createElement("div");
      const dt = document.createElement("dt");
      dt.textContent = label;
      const dd = document.createElement("dd");
      dd.textContent = value;
      row.append(dt, dd);
      figures.appendChild(row);
    }
    this.sheetBody.appendChild(figures);

    if (record.description) {
      const description = document.createElement("p");
      description.className = "deck-sheet__body";
      description.textContent = record.description;
      this.sheetBody.appendChild(description);
    }

    if (record.variant_id) {
      const form = document.createElement("div");
      form.className = "deck-sheet__buy";

      const select = document.createElement("select");
      select.className = "deck-sheet__select";
      select.setAttribute("aria-label", "Edition");
      for (const edition of record.editions) {
        const option = document.createElement("option");
        option.value = edition.id;
        option.textContent = `${edition.name} - ${edition.price}`;
        select.appendChild(option);
      }

      const button = document.createElement("button");
      button.type = "button";
      button.className = "deck-sheet__button";
      button.textContent = "Add to basket";
      button.addEventListener("click", () => this.add(record, select.value, button));

      form.append(select, button);
      this.sheetBody.appendChild(form);
    } else {
      const note = document.createElement("p");
      note.className = "deck-sheet__body";
      note.textContent = "No edition of this object is available right now.";
      this.sheetBody.appendChild(note);
    }

    const link = document.createElement("a");
    link.className = "deck-sheet__link";
    link.href = record.url;
    link.textContent = "Open the full record";
    this.sheetBody.appendChild(link);

    this.sheet.hidden = false;
    // The sheet takes focus, not its close button: focusing the button meant
    // the next Enter press activated it and shut the sheet again.
    this.sheet.setAttribute("tabindex", "-1");
    this.sheet.focus();
  }

  async add(record, variantId, button) {
    button.disabled = true;
    button.textContent = "Adding ...";

    const body = new FormData();
    body.append("variant_id", variantId);
    body.append("quantity", "1");

    try {
      const response = await fetch(record.cart_url, {
        method: "POST",
        headers: { "X-CSRF-Token": this.csrf, "Accept": "text/html" },
        body,
        credentials: "same-origin"
      });
      if (response.ok || response.redirected) {
        button.textContent = "In the basket";
      } else {
        button.disabled = false;
        button.textContent = "Try again";
      }
    } catch (error) {
      button.disabled = false;
      button.textContent = "Try again";
    }
  }

  close() {
    if (this.sheet) this.sheet.hidden = true;
  }
}

new Deck();
