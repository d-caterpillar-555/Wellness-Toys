import { Controller } from "@hotwired/stimulus"

// Content resolves into place as you reach it.
//
// The finished state is the page's default and this controller is what opts the
// document into motion at all: nothing on the site is hidden until
// `data-motion="ready"` is set here on connect. So a visitor without JavaScript,
// or with a script that fails to load, reads a complete page rather than a
// blank one — the failure mode this pattern exists to prevent.
//
// Two beats, both additive: the container rises 12px into focus, and any group
// inside it cascades its children by index. IntersectionObserver rather than a
// scroll listener. Transform and opacity only.
export default class extends Controller {
  connect() {
    if (this.prefersReducedMotion) {
      this.element.dataset.revealed = "true"
      return
    }

    document.documentElement.dataset.motion = "ready"
    this.indexGroups()

    this.observer = new IntersectionObserver(this.reveal.bind(this), {
      rootMargin: "0px 0px -12% 0px",
      threshold: 0.08
    })

    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
  }

  reveal(entries) {
    for (const entry of entries) {
      if (!entry.isIntersecting) continue

      entry.target.dataset.revealed = "true"
      this.observer.unobserve(entry.target)
    }
  }

  // The cascade index is written as a custom property so the delay stays in the
  // stylesheet. Past the eighth child the cascade stops advancing — a long list
  // arrives together rather than making the reader wait for its tail.
  indexGroups() {
    this.groupedChildren.forEach((child, index) => {
      child.style.setProperty("--i", Math.min(index, 8))
    })
  }

  get groupedChildren() {
    return this.element.querySelectorAll("[data-reveal-group] > *")
  }

  get prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
