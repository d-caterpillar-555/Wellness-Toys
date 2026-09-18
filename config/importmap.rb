# What the browser is allowed to import by bare name.
#
# The framework comes from the gems' own pinned assets; the app's controllers
# are pinned from the tree so each one is a module the browser fetches on
# demand. There is no Node build step: this file is the whole module path.
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

pin "application"
pin_all_from "app/javascript/controllers", under: "controllers"
