Rails.application.routes.draw do
  # Health check for load balancers and uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  # --- Static pages ---------------------------------------------------------
  # An explicit allowlist rather than a catch-all, so an unknown path is a
  # genuine 404 rather than a database lookup on every request.
  #
  # A local variable, not a constant: routes are reloaded, and a constant would
  # warn about reinitialisation on every reload.
  page_slugs = %w[
    about standards contact shipping returns privacy terms accessibility
    discreet-shipping faq
  ]

  page_slugs.each do |slug|
    get "/#{slug}", to: "pages#show", defaults: { slug: slug }, as: :"page_#{slug.tr('-', '_')}"
  end
end
