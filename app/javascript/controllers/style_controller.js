import { Controller } from "@hotwired/stimulus"

// The world switch: three editorial worlds and four storefronts.
//
// One attribute on <html> moves the whole site between token sets, the same
// way data-theme moves it between light and dark. All the worlds are on screen
// at once and the live one is marked, so the control states where you are
// instead of asking you to remember a cycle.
//
// The list of worlds comes from the buttons themselves. It used to be written
// out here as well, and the two copies drifted: a query parameter for a world
// this file had not heard of was quietly ignored. Now there is one list.
export default class extends Controller {
  static targets = ["option"]

  connect() {
    this.paint()
  }

  apply(event) {
    const style = event.currentTarget.dataset.styleName
    if (!style) return

    this.#set(style)
  }

  // Kept for anything that wants to step through the worlds in order.
  cycle() {
    const styles = this.styles
    const next = styles[(styles.indexOf(this.current) + 1) % styles.length]
    this.#set(next)
  }

  #set(style) {
    document.documentElement.dataset.style = style

    try {
      localStorage.setItem("wt-style", style)
    } catch (e) {
      // Storage can be unavailable in private modes. The world still applies
      // for this page view, which is an acceptable degradation.
    }

    this.paint()
  }

  paint() {
    for (const option of this.optionTargets) {
      const active = option.dataset.styleName === this.current
      option.dataset.active = active ? "true" : "false"
      option.setAttribute("aria-pressed", active ? "true" : "false")
    }
  }

  get styles() {
    return this.optionTargets.map((option) => option.dataset.styleName)
  }

  get current() {
    return document.documentElement.dataset.style || this.styles[0]
  }
}
