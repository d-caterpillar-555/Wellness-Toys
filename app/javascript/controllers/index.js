import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

// Every controller in this directory is registered at load. They are small and
// each one is only instantiated where its data-controller appears, so there is
// nothing to be gained from lazy registration here.
eagerLoadControllersFrom("controllers", application)
