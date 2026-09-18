// The one entry point the layout asks for.
//
// Turbo first, because it is what makes navigation and form submissions feel
// like an application rather than a series of page loads; then the controllers,
// which are registered by the autoloader from the same tree.
import "@hotwired/turbo-rails"
import "controllers"
