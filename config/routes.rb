Rails.application.routes.draw do
  # Health check for load balancers and uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  # --- The eight architectures ----------------------------------------------
  # The site's default architecture (institute) is the canonical routes below.
  # The other seven are alternate architectures, each with its own prefix, its
  # own page inventory and its own layout - see docs/eight-worlds.md. Their
  # routes are drawn next to the world they belong to, further down this file.
  get "/worlds", to: "worlds#index", as: :worlds

  # --- Shop -----------------------------------------------------------------
  get "/shop", to: "products#index", as: :shop
  get "/collections/:slug", to: "collections#show", as: :collection
  get "/search", to: "searches#show", as: :search
  # Most specific first. The category segment is validated against existing
  # slugs by the controller, so a bad segment is a 404 rather than a product
  # lookup.
  get "/shop/:category_slug", to: "categories#show", as: :category
  get "/shop/:category_slug/:slug", to: "products#show", as: :product

  # --- Cart -----------------------------------------------------------------
  # State changes are resources rather than custom actions on an existing
  # resource, per the routing convention in skills.md.
  resource :cart, only: [ :show ] do
    resources :items, only: [ :create, :update, :destroy ], module: :cart
  end

  # --- Checkout and orders --------------------------------------------------
  resource :checkout, only: [ :new, :create ]
  get "/orders/:public_token", to: "orders#show", as: :order

  # --- Accounts -------------------------------------------------------------
  devise_for :users,
    path: "account",
    controllers: { registrations: "users/registrations", passwords: "users/passwords" },
    skip: [ :sessions ]

  # Devise's session routes are redefined so the sign-in action can be rate
  # limited alongside the other authentication endpoints.
  devise_scope :user do
    get "/account/sign_in", to: "users/sessions#new", as: :new_user_session
    post "/account/sign_in", to: "users/sessions#create", as: :user_session
    delete "/account/sign_out", to: "users/sessions#destroy", as: :destroy_user_session
  end

  namespace :account do
    root "dashboard#show"
    resource :profile, only: [ :show, :edit, :update ]
    resources :orders, only: [ :index, :show ], param: :number
    resources :addresses, except: [ :show ]
    resources :data_requests, only: [ :index, :new, :create ]
    resource :consent, only: [ :show, :update ]
  end

  # --- Learn ----------------------------------------------------------------
  # Evergreen education. Separate from /blog, which carries timely posts.
  get "/learn", to: "topics#index", as: :learn
  get "/learn/glossary", to: "glossary#index", as: :learn_glossary
  get "/learn/glossary/:term", to: "glossary#show", as: :learn_glossary_term
  get "/learn/experts", to: "authors#index", as: :learn_experts
  get "/learn/experts/:slug", to: "authors#show", as: :learn_expert
  get "/learn/:topic_slug", to: "topics#show", as: :learn_topic
  get "/learn/:topic_slug/:slug", to: "articles#show", as: :learn_article

  # --- Blog -----------------------------------------------------------------
  get "/blog", to: "posts#index", as: :blog
  get "/blog/:slug", to: "posts#show", as: :blog_post

  # --- Consent --------------------------------------------------------------
  resource :consent, only: [ :create ], controller: "consent" do
    post :withdraw
  end

  # --- Age gate -------------------------------------------------------------
  # A soft gate: it records an acknowledgement rather than blocking at the edge.
  resource :age_confirmation, only: [ :create ]

  # --- Machine-readable -----------------------------------------------------
  get "/sitemap.xml", to: "sitemaps#show", as: :sitemap, defaults: { format: "xml" }
  get "/robots.txt", to: "robots#show", as: :robots, defaults: { format: "text" }

  # --- Static pages ---------------------------------------------------------
  # An explicit allowlist rather than a catch-all, so an unknown path is a
  # genuine 404 rather than a database lookup on every request.
  #
  # The list lives on the Page model, because the sitemap needs the same list
  # and a second copy would drift.
  Page::ROUTED_SLUGS.each do |slug|
    get "/#{slug}", to: "pages#show", defaults: { slug: slug }, as: :"page_#{slug.tr('-', '_')}"
  end

  # --- The worlds -----------------------------------------------------------
  # One prefix per architecture, each with its own page inventory. Institute,
  # the default, is the canonical routes above; these are the other seven.
  # See docs/eight-worlds.md.

  scope module: "worlds" do
    # folio: the whole shop as one continuous document. Its addresses are
    # anchors on /folio; the print view is the same document without furniture.
    get "/folio", to: "folio#index", as: :folio
    get "/folio/print", to: "folio#print", as: :folio_print

    # figure: the scroll choreography. One story, a catalogue with poses on
    # hover, and one piece at a time.
    get "/figure", to: "figure#index", as: :figure
    get "/figure/pieces", to: "figure#pieces", as: :figure_pieces
    get "/figure/pieces/:slug", to: "figure#piece", as: :figure_piece

    # plan: a floor plan. Departments are rooms; a product is an object on the
    # plan, drawn with its callout. The register is the same data without the
    # walking.
    get "/plan", to: "plan#index", as: :plan
    get "/plan/register", to: "plan#register", as: :plan_register
    get "/plan/room/:slug", to: "plan#room", as: :plan_room
    get "/plan/object/:slug", to: "plan#object", as: :plan_object

    # shell: one surface. Paths resolve against the catalogue, the library and
    # the reference pages; /shell/object/:slug opens the machine with that
    # object already printed.
    get "/shell", to: "shell#index", as: :shell
    get "/shell/object/:slug", to: "shell#object", as: :shell_object

    # press: a newspaper. A front page, the review section, the issue's
    # features, a story reprinted with its sources, and the notices.
    get "/press", to: "press#index", as: :press
    get "/press/catalogue", to: "press#reviews", as: :press_catalogue
    get "/press/issue", to: "press#issue", as: :press_issue
    get "/press/story/:topic_slug/:slug", to: "press#story", as: :press_story
    get "/press/notices", to: "press#notices", as: :press_notices
  end

  # --- Admin ----------------------------------------------------------------
  mount Avo::Engine, at: "/admin"
end
