import { Controller } from "@hotwired/stimulus"

// Theme toggle. The initial value is resolved before first paint by the inline
// script in the layout, so this controller only handles switching and storage.
//
// Where the View Transitions API exists, the swap is wrapped in one, so the
// page turns over instead of flickering between two palettes. Reduced motion
// skips the transition and swaps instantly.
export default class extends Controller {
  connect() {
    this.updateLabel()
  }

  toggle() {
    const next = this.current === "dark" ? "light" : "dark"

    if (this.canTransition) {
      document.startViewTransition(() => this.apply(next))
    } else {
      this.apply(next)
    }

    try {
      localStorage.setItem("wt-theme", next)
    } catch (e) {
      // Storage can be unavailable in private modes. The theme still applies
      // for this page view, which is an acceptable degradation.
    }
  }

  apply(theme) {
    document.documentElement.dataset.theme = theme
    this.updateLabel()
  }

  get canTransition() {
    return typeof document.startViewTransition === "function" && !this.prefersReducedMotion
  }

  get prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  get current() {
    return document.documentElement.dataset.theme === "dark" ? "dark" : "light"
  }

  updateLabel() {
    const label = this.element.querySelector("[data-theme-target='label']")
    if (!label) return

    label.textContent = this.current === "dark" ? "Light" : "Dark"
  }
}
