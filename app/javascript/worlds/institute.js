// Institute: the contents rail knows where you are.
//
// One IntersectionObserver over the page's clauses marks the current entry.
// No scroll listener, no layout reads on every frame: the observer fires when a
// clause crosses the reading line, and one attribute changes.
export default class Institute {
  constructor(root = document) {
    this.rail = root.querySelector("[data-institute-rail]")
    this.clauses = Array.from(root.querySelectorAll("[data-institute-clause]"))
    if (!this.rail || this.clauses.length === 0) return

    this.links = new Map()
    for (const link of this.rail.querySelectorAll(".inst-rail__link")) {
      const id = link.getAttribute("href")?.slice(1)
      if (id) this.links.set(id, link)
    }
    if (this.links.size === 0) return

    this.activate(this.clauses[0].id)

    this.observer = new IntersectionObserver(
      (entries) => this.onIntersect(entries),
      // A clause counts as current once its heading has passed the upper third
      // of the viewport, which is where a reader's eye actually is.
      { rootMargin: "-20% 0px -65% 0px", threshold: 0 }
    )
    for (const clause of this.clauses) this.observer.observe(clause)
  }

  onIntersect(entries) {
    const visible = entries
      .filter((entry) => entry.isIntersecting)
      .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top)

    if (visible.length > 0) {
      this.activate(visible[0].target.id)
      return
    }

    // Nothing is crossing the line: the reader is above the first clause or
    // below the last, so mark the nearest one that is still above the line.
    const passed = this.clauses.filter((clause) => clause.getBoundingClientRect().top < window.innerHeight * 0.35)
    if (passed.length > 0) this.activate(passed[passed.length - 1].id)
  }

  activate(id) {
    for (const [key, link] of this.links) {
      if (key === id) {
        link.setAttribute("aria-current", "true")
      } else {
        link.removeAttribute("aria-current")
      }
    }
  }
}

new Institute()
