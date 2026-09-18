import { Application } from "@hotwired/stimulus"

// The Stimulus application every controller in this tree registers with.
const application = Application.start()

// Debug logging stays off: this is a store, not a workbench. It is exposed on
// window so a browser console can still introspect the app when needed.
application.debug = false
window.Stimulus = application

export { application }
