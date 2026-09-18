class CreateShopCatalog < ActiveRecord::Migration[8.1]
  def change
    # Trigram matching backs the search fallback if Meilisearch is unavailable,
    # and powers admin filtering. It is an index aid, never a source of truth.
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    create_table :brands do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :country_code
      t.string :website_url
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :brands, :slug, unique: true
    add_index :brands, :discarded_at

    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.references :parent, foreign_key: { to_table: :categories }
      t.integer :position, null: false, default: 0
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :categories, :slug, unique: true
    add_index :categories, [ :parent_id, :position ]
    add_index :categories, :discarded_at
    add_check_constraint :categories, "parent_id IS NULL OR parent_id <> id",
      name: "categories_parent_not_self"

    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :sku, null: false
      t.string :subtitle
      t.text :description
      t.text :materials
      t.text :care_instructions
      t.text :safety_notes
      t.string :dimensions
      t.integer :weight_grams
      t.boolean :body_safe, null: false, default: true
      t.string :status, null: false, default: "draft"
      t.datetime :published_at
      t.references :brand, foreign_key: true
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true
    add_index :products, :status
    add_index :products, :published_at
    add_index :products, :discarded_at
    add_index :products, :name, opclass: :gin_trgm_ops, using: :gin
    add_check_constraint :products,
      "status IN ('draft', 'active', 'archived')",
      name: "products_status_is_known"
    add_check_constraint :products,
      "weight_grams IS NULL OR weight_grams > 0",
      name: "products_weight_is_positive"
    add_check_constraint :products,
      "status <> 'active' OR published_at IS NOT NULL",
      name: "products_active_are_published"

    create_table :product_categories do |t|
      t.references :product, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :product_categories, [ :product_id, :category_id ], unique: true
    add_index :product_categories, [ :category_id, :position ]

    create_table :variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name, null: false
      t.string :sku, null: false
      t.integer :price_cents, null: false
      t.integer :compare_at_price_cents
      t.string :currency, null: false, default: "USD"
      t.integer :stock_quantity, null: false, default: 0
      t.integer :weight_grams
      t.boolean :active, null: false, default: true
      t.jsonb :options, null: false, default: {}
      t.integer :position, null: false, default: 0
      t.datetime :discarded_at
      t.timestamps
    end
    add_index :variants, :sku, unique: true
    add_index :variants, [ :product_id, :position ]
    add_index :variants, :discarded_at
    add_index :variants, :options, using: :gin
    add_check_constraint :variants, "price_cents > 0", name: "variants_price_is_positive"
    add_check_constraint :variants, "stock_quantity >= 0", name: "variants_stock_is_not_negative"
    add_check_constraint :variants,
      "compare_at_price_cents IS NULL OR compare_at_price_cents > price_cents",
      name: "variants_compare_at_exceeds_price"
    add_check_constraint :variants,
      "char_length(currency) = 3 AND currency = upper(currency)",
      name: "variants_currency_is_iso_code"
    add_check_constraint :variants,
      "jsonb_typeof(options) = 'object'",
      name: "variants_options_is_object"
  end
end
