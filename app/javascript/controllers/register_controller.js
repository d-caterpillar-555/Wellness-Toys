import { Controller } from "@hotwired/stimulus"

// The contents rail on a long document: which section the reader is in.
//
// One IntersectionObserver over the sections themselves. The band across the
// middle of the viewport decides, so the mark moves when a section actually
// takes over the page rather than when its first pixel appears.
export default class extends Controller {
  static targets = ["section", "link"]

  connect() {
    this.observer = new IntersectionObserver(this.activate.bind(this), {
      rootMargin: "-45% 0px -50% 0px"
    })

    for (const section of this.sectionTargets) {
      this.observer.observe(section)
    }
  }

  disconnect() {
    this.observer?.disconnect()
  }

  activate(entries) {
    for (const entry of entries) {
      if (entry.isIntersecting) this.mark(entry.target.id)
    }
  }

  mark(id) {
    for (const link of this.linkTargets) {
      if (link.getAttribute("href") === `#${id}`) {
        link.setAttribute("aria-current", "true")
      } else {
        link.removeAttribute("aria-current")
      }
    }
  }
}
