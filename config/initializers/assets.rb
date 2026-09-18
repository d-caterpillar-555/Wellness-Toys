# Be sure to restart your server when you modify this file.

Rails.application.config.assets.version = "1.0"

# Tailwind compiles app/assets/tailwind/application.css into
# app/assets/builds/tailwind.css. Propshaft only serves what it can find on its
# load path, and the builds directory is not on it by default, so without this
# line the compiled stylesheet 404s.
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")
