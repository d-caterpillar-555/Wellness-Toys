# What the browser is allowed to import by bare name.
#
# The framework comes from the gems' own pinned assets; the app's controllers
# and the world modules are pinned from the tree so each one is a module the
# browser fetches on demand. There is no Node build step: this file is the whole
# module path.
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

pin "application"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/worlds", under: "worlds"
# What more than one world borrows: a scrubbed frame sequence is the same
# instrument in figure and in folio, so it lives in one file.
pin_all_from "app/javascript/lib", under: "lib"
