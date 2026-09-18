import { Controller } from "@hotwired/stimulus"

// Theme toggle. The initial value is resolved before first paint by the inline
// script in the layout, so this controller only handles switching and storage.
export default class extends Controller {
  connect() {
    this.updateLabel()
  }

  toggle() {
    const next = this.current === "dark" ? "light" : "dark"
    document.documentElement.dataset.theme = next

    try {
      localStorage.setItem("wt-theme", next)
    } catch (e) {
      // Storage can be unavailable in private modes. The theme still applies
      // for this page view, which is an acceptable degradation.
    }

    this.updateLabel()
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
