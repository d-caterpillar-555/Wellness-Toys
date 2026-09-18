import { Controller } from "@hotwired/stimulus"

// The single authored motion moment on the site: content resolves into place
// as you reach it.
//
// The element is visible by default and this controller only ever adds the
// revealed state, so a visitor with JavaScript disabled or reduced motion
// enabled sees finished content rather than a blank page. IntersectionObserver
// is used instead of a scroll listener, and only opacity and transform animate.
export default class extends Controller {
  connect() {
    if (this.prefersReducedMotion) {
      this.element.dataset.revealed = "true"
      return
    }

    this.observer = new IntersectionObserver(this.reveal.bind(this), {
      rootMargin: "0px 0px -10% 0px",
      threshold: 0.1
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

  get prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
