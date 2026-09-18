# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_18_163008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "city", null: false
    t.string "country_code", null: false
    t.datetime "created_at", precision: nil, null: false
    t.boolean "default_billing", default: false, null: false
    t.boolean "default_shipping", default: false, null: false
    t.datetime "discarded_at", precision: nil
    t.string "label"
    t.text "line1", null: false
    t.text "line2"
    t.string "postal_code", null: false
    t.string "recipient", null: false
    t.string "region"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id", null: false
    t.index ["discarded_at"], name: "index_addresses_on_discarded_at"
    t.index ["user_id"], name: "addresses_one_default_billing_per_user", unique: true, where: "(default_billing AND (discarded_at IS NULL))"
    t.index ["user_id"], name: "addresses_one_default_shipping_per_user", unique: true, where: "(default_shipping AND (discarded_at IS NULL))"
    t.index ["user_id"], name: "index_addresses_on_user_id"
    t.check_constraint "NOT (default_shipping AND default_billing)", name: "addresses_defaults_are_distinct"
    t.check_constraint "char_length(TRIM(BOTH FROM recipient)) > 0", name: "addresses_recipient_is_present"
    t.check_constraint "char_length(country_code::text) = 2 AND country_code::text = upper(country_code::text)", name: "addresses_country_is_iso_code"
  end

  create_table "article_topics", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.datetime "created_at", null: false
    t.bigint "topic_id", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id", "topic_id"], name: "index_article_topics_on_article_id_and_topic_id", unique: true
    t.index ["article_id"], name: "index_article_topics_on_article_id"
    t.index ["topic_id"], name: "index_article_topics_on_topic_id"
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "author_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "excerpt"
    t.string "kind", default: "guide", null: false
    t.bigint "primary_topic_id"
    t.datetime "published_at"
    t.integer "reading_minutes"
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_articles_on_author_id"
    t.index ["discarded_at"], name: "index_articles_on_discarded_at"
    t.index ["kind"], name: "index_articles_on_kind"
    t.index ["primary_topic_id"], name: "index_articles_on_primary_topic_id"
    t.index ["published_at"], name: "index_articles_on_published_at"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
    t.index ["status"], name: "index_articles_on_status"
    t.index ["title"], name: "index_articles_on_title", opclass: :gin_trgm_ops, using: :gin
    t.check_constraint "kind::text = ANY (ARRAY['guide'::character varying, 'pillar'::character varying, 'glossary'::character varying, 'post'::character varying]::text[])", name: "articles_kind_is_known"
    t.check_constraint "reading_minutes IS NULL OR reading_minutes > 0", name: "articles_reading_minutes_is_positive"
    t.check_constraint "status::text <> 'published'::text OR published_at IS NOT NULL", name: "articles_published_are_timestamped"
    t.check_constraint "status::text = ANY (ARRAY['draft'::character varying, 'published'::character varying, 'archived'::character varying]::text[])", name: "articles_status_is_known"
  end

  create_table "audit_events", force: :cascade do |t|
    t.string "action", null: false
    t.bigint "actor_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "ip_hash"
    t.jsonb "metadata", default: {}, null: false
    t.bigint "subject_id"
    t.string "subject_type"
    t.index ["action"], name: "index_audit_events_on_action"
    t.index ["actor_id", "created_at"], name: "index_audit_events_on_actor_id_and_created_at"
    t.index ["actor_id"], name: "index_audit_events_on_actor_id"
    t.index ["created_at"], name: "index_audit_events_on_created_at"
    t.index ["metadata"], name: "index_audit_events_on_metadata", using: :gin
    t.index ["subject_type", "subject_id"], name: "index_audit_events_on_subject_type_and_subject_id"
    t.check_constraint "char_length(action::text) > 0", name: "audit_events_action_is_present"
    t.check_constraint "jsonb_typeof(metadata) = 'object'::text", name: "audit_events_metadata_is_object"
  end

  create_table "authors", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "credentials"
    t.datetime "discarded_at"
    t.boolean "is_clinician", default: false, null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.index ["discarded_at"], name: "index_authors_on_discarded_at"
    t.index ["slug"], name: "index_authors_on_slug", unique: true
  end

  create_table "brands", force: :cascade do |t|
    t.string "country_code"
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.datetime "discarded_at", precision: nil
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "website_url"
    t.index ["discarded_at"], name: "index_brands_on_discarded_at"
    t.index ["slug"], name: "index_brands_on_slug", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "variant_id", null: false
    t.index ["cart_id", "variant_id"], name: "index_cart_items_on_cart_id_and_variant_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["variant_id"], name: "index_cart_items_on_variant_id"
    t.check_constraint "quantity <= 100", name: "cart_items_quantity_is_sane"
    t.check_constraint "quantity > 0", name: "cart_items_quantity_is_positive"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "guest_token"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["guest_token"], name: "index_carts_on_guest_token", unique: true, where: "(guest_token IS NOT NULL)"
    t.index ["user_id"], name: "carts_one_per_user", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["user_id"], name: "index_carts_on_user_id"
    t.check_constraint "(user_id IS NOT NULL) <> (guest_token IS NOT NULL)", name: "carts_have_exactly_one_owner"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.datetime "discarded_at", precision: nil
    t.string "name", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["discarded_at"], name: "index_categories_on_discarded_at"
    t.index ["parent_id", "position"], name: "index_categories_on_parent_id_and_position"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
    t.check_constraint "parent_id IS NULL OR parent_id <> id", name: "categories_parent_not_self"
  end

  create_table "consent_records", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "granted_at", precision: nil, null: false
    t.string "ip_hash"
    t.string "kind", null: false
    t.string "policy_version", null: false
    t.datetime "revoked_at", precision: nil
    t.string "subject_token", null: false
    t.string "user_agent_hash"
    t.bigint "user_id"
    t.index ["created_at"], name: "index_consent_records_on_created_at"
    t.index ["kind"], name: "consent_records_active_by_kind", where: "(revoked_at IS NULL)"
    t.index ["subject_token", "kind"], name: "index_consent_records_on_subject_token_and_kind"
    t.index ["user_id", "kind"], name: "index_consent_records_on_user_id_and_kind"
    t.index ["user_id"], name: "index_consent_records_on_user_id"
    t.check_constraint "char_length(policy_version::text) > 0", name: "consent_records_policy_version_present"
    t.check_constraint "kind::text = ANY (ARRAY['functional'::character varying, 'analytics'::character varying, 'marketing'::character varying]::text[])", name: "consent_records_kind_is_known"
    t.check_constraint "revoked_at IS NULL OR revoked_at >= granted_at", name: "consent_records_revoked_after_granted"
  end

  create_table "data_requests", force: :cascade do |t|
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "kind", null: false
    t.text "note"
    t.datetime "requested_at", precision: nil, null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id", null: false
    t.index ["status"], name: "index_data_requests_on_status"
    t.index ["user_id", "kind"], name: "index_data_requests_on_user_id_and_kind"
    t.index ["user_id"], name: "index_data_requests_on_user_id"
    t.check_constraint "kind::text = ANY (ARRAY['export'::character varying, 'delete'::character varying]::text[])", name: "data_requests_kind_is_known"
    t.check_constraint "status::text <> 'completed'::text OR completed_at IS NOT NULL", name: "data_requests_completed_are_timestamped"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'processing'::character varying, 'completed'::character varying, 'rejected'::character varying]::text[])", name: "data_requests_status_is_known"
  end

  create_table "faqs", force: :cascade do |t|
    t.text "answer", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.bigint "faqable_id", null: false
    t.string "faqable_type", null: false
    t.integer "position", default: 0, null: false
    t.string "question", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_faqs_on_discarded_at"
    t.index ["faqable_type", "faqable_id", "position"], name: "index_faqs_on_faqable_type_and_faqable_id_and_position"
    t.index ["faqable_type", "faqable_id"], name: "index_faqs_on_faqable"
    t.check_constraint "char_length(TRIM(BOTH FROM answer)) > 0", name: "faqs_answer_present"
    t.check_constraint "char_length(TRIM(BOTH FROM question)) > 0", name: "faqs_question_present"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "newsletter_subscribers", force: :cascade do |t|
    t.datetime "consented_at", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "email", null: false
    t.string "source"
    t.datetime "unsubscribed_at"
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_newsletter_subscribers_on_discarded_at"
    t.index ["email"], name: "index_newsletter_subscribers_on_email", unique: true
    t.check_constraint "unsubscribed_at IS NULL OR unsubscribed_at >= consented_at", name: "newsletter_unsubscribed_after_consented"
  end

  create_table "order_events", force: :cascade do |t|
    t.bigint "actor_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "kind", null: false
    t.text "note"
    t.bigint "order_id", null: false
    t.string "to_status"
    t.index ["actor_id"], name: "index_order_events_on_actor_id"
    t.index ["kind"], name: "index_order_events_on_kind"
    t.index ["order_id", "created_at"], name: "index_order_events_on_order_id_and_created_at"
    t.index ["order_id"], name: "index_order_events_on_order_id"
    t.check_constraint "char_length(kind::text) > 0", name: "order_events_kind_is_present"
    t.check_constraint "to_status IS NULL OR (to_status::text = ANY (ARRAY['pending'::character varying, 'confirmed'::character varying, 'processing'::character varying, 'shipped'::character varying, 'delivered'::character varying, 'cancelled'::character varying]::text[]))", name: "order_events_status_is_known"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "currency", default: "USD", null: false
    t.integer "line_total_cents", null: false
    t.bigint "order_id", null: false
    t.string "product_name", null: false
    t.integer "quantity", null: false
    t.string "sku", null: false
    t.integer "unit_price_cents", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "variant_id"
    t.string "variant_name", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["variant_id"], name: "index_order_items_on_variant_id"
    t.check_constraint "line_total_cents = (unit_price_cents * quantity)", name: "order_items_line_total_is_consistent"
    t.check_constraint "line_total_cents >= 0", name: "order_items_line_total_not_negative"
    t.check_constraint "quantity > 0", name: "order_items_quantity_is_positive"
    t.check_constraint "unit_price_cents >= 0", name: "order_items_unit_price_not_negative"
  end

  create_table "orders", force: :cascade do |t|
    t.string "checkout_token", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "currency", default: "USD", null: false
    t.datetime "discarded_at", precision: nil
    t.string "email", null: false
    t.text "note"
    t.string "number", null: false
    t.string "payment_status", default: "awaiting_invoice", null: false
    t.datetime "placed_at", precision: nil
    t.string "public_token", null: false
    t.string "ship_to_city", null: false
    t.string "ship_to_country_code", null: false
    t.string "ship_to_line1", null: false
    t.string "ship_to_line2"
    t.string "ship_to_postal_code", null: false
    t.string "ship_to_recipient", null: false
    t.string "ship_to_region"
    t.integer "shipping_cents", default: 0, null: false
    t.string "status", default: "pending", null: false
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "tax_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["checkout_token"], name: "index_orders_on_checkout_token", unique: true
    t.index ["discarded_at"], name: "index_orders_on_discarded_at"
    t.index ["number"], name: "index_orders_on_number", unique: true
    t.index ["placed_at"], name: "index_orders_on_placed_at"
    t.index ["public_token"], name: "index_orders_on_public_token", unique: true
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id", "created_at"], name: "index_orders_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.check_constraint "char_length(currency::text) = 3 AND currency::text = upper(currency::text)", name: "orders_currency_is_iso_code"
    t.check_constraint "char_length(public_token::text) >= 22", name: "orders_public_token_is_long_enough"
    t.check_constraint "char_length(ship_to_country_code::text) = 2 AND ship_to_country_code::text = upper(ship_to_country_code::text)", name: "orders_country_is_iso_code"
    t.check_constraint "payment_status::text = ANY (ARRAY['awaiting_invoice'::character varying, 'unpaid'::character varying, 'paid'::character varying, 'refunded'::character varying, 'failed'::character varying]::text[])", name: "orders_payment_status_is_known"
    t.check_constraint "shipping_cents >= 0", name: "orders_shipping_not_negative"
    t.check_constraint "status::text <> 'confirmed'::text OR placed_at IS NOT NULL", name: "orders_confirmed_are_placed"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'confirmed'::character varying, 'processing'::character varying, 'shipped'::character varying, 'delivered'::character varying, 'cancelled'::character varying]::text[])", name: "orders_status_is_known"
    t.check_constraint "subtotal_cents >= 0", name: "orders_subtotal_not_negative"
    t.check_constraint "tax_cents >= 0", name: "orders_tax_not_negative"
    t.check_constraint "total_cents >= 0", name: "orders_total_not_negative"
  end

  create_table "pages", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "discarded_at", precision: nil
    t.string "meta_description"
    t.string "meta_title"
    t.integer "position", default: 0, null: false
    t.datetime "published_at", precision: nil
    t.boolean "show_in_footer", default: false, null: false
    t.string "slug", null: false
    t.string "subtitle"
    t.string "title", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["discarded_at"], name: "index_pages_on_discarded_at"
    t.index ["position", "title"], name: "index_pages_on_position_and_title"
    t.index ["slug"], name: "index_pages_on_slug", unique: true
  end

  create_table "product_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "position", default: 0, null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["category_id", "position"], name: "index_product_categories_on_category_id_and_position"
    t.index ["category_id"], name: "index_product_categories_on_category_id"
    t.index ["product_id", "category_id"], name: "index_product_categories_on_product_id_and_category_id", unique: true
    t.index ["product_id"], name: "index_product_categories_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "body_safe", default: true, null: false
    t.bigint "brand_id"
    t.text "care_instructions"
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.string "dimensions"
    t.datetime "discarded_at", precision: nil
    t.text "materials"
    t.string "name", null: false
    t.datetime "published_at", precision: nil
    t.text "safety_notes"
    t.string "sku", null: false
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.string "subtitle"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "weight_grams"
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["discarded_at"], name: "index_products_on_discarded_at"
    t.index ["name"], name: "index_products_on_name", opclass: :gin_trgm_ops, using: :gin
    t.index ["published_at"], name: "index_products_on_published_at"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["status"], name: "index_products_on_status"
    t.check_constraint "status::text <> 'active'::text OR published_at IS NOT NULL", name: "products_active_are_published"
    t.check_constraint "status::text = ANY (ARRAY['draft'::character varying, 'active'::character varying, 'archived'::character varying]::text[])", name: "products_status_is_known"
    t.check_constraint "weight_grams IS NULL OR weight_grams > 0", name: "products_weight_is_positive"
  end

  create_table "redirects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "from_path", null: false
    t.integer "status_code", default: 301, null: false
    t.string "to_path", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_redirects_on_discarded_at"
    t.index ["from_path"], name: "index_redirects_on_from_path", unique: true
    t.check_constraint "from_path::text <> to_path::text", name: "redirects_do_not_loop_to_self"
    t.check_constraint "from_path::text ~ '^/'::text AND to_path::text ~ '^/'::text", name: "redirects_paths_are_absolute"
    t.check_constraint "status_code = ANY (ARRAY[301, 302, 307, 308])", name: "redirects_status_is_permanent_or_temporary"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.bigint "product_id", null: false
    t.datetime "published_at"
    t.integer "rating", null: false
    t.string "status", default: "pending", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "verified_purchase", default: false, null: false
    t.index ["discarded_at"], name: "index_reviews_on_discarded_at"
    t.index ["product_id", "status"], name: "index_reviews_on_product_id_and_status"
    t.index ["product_id", "user_id"], name: "index_reviews_on_product_id_and_user_id", unique: true
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
    t.check_constraint "rating >= 1 AND rating <= 5", name: "reviews_rating_in_range"
    t.check_constraint "status::text <> 'approved'::text OR published_at IS NOT NULL", name: "reviews_approved_are_published"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying, 'approved'::character varying, 'rejected'::character varying]::text[])", name: "reviews_status_is_known"
  end

  create_table "sources", force: :cascade do |t|
    t.bigint "article_id", null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.date "published_on"
    t.string "publisher", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["article_id", "position"], name: "index_sources_on_article_id_and_position"
    t.index ["article_id"], name: "index_sources_on_article_id"
    t.check_constraint "char_length(TRIM(BOTH FROM publisher)) > 0", name: "sources_publisher_present"
    t.check_constraint "char_length(TRIM(BOTH FROM title)) > 0", name: "sources_title_present"
    t.check_constraint "url::text ~ '^https?://'::text", name: "sources_url_is_absolute"
  end

  create_table "topics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.string "name", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_topics_on_discarded_at"
    t.index ["parent_id", "position"], name: "index_topics_on_parent_id_and_position"
    t.index ["parent_id"], name: "index_topics_on_parent_id"
    t.index ["slug"], name: "index_topics_on_slug", unique: true
    t.check_constraint "parent_id IS NULL OR parent_id <> id", name: "topics_parent_not_self"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "age_confirmed_at", precision: nil, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "discarded_at", precision: nil
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.text "phone"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.string "role", default: "customer", null: false
    t.datetime "terms_accepted_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.check_constraint "email::text ~ '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$'::text", name: "users_email_has_shape"
    t.check_constraint "role::text = ANY (ARRAY['customer'::character varying, 'editor'::character varying, 'admin'::character varying]::text[])", name: "users_role_is_known"
  end

  create_table "variants", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "compare_at_price_cents"
    t.datetime "created_at", precision: nil, null: false
    t.string "currency", default: "USD", null: false
    t.datetime "discarded_at", precision: nil
    t.string "name", null: false
    t.jsonb "options", default: {}, null: false
    t.integer "position", default: 0, null: false
    t.integer "price_cents", null: false
    t.bigint "product_id", null: false
    t.string "sku", null: false
    t.integer "stock_quantity", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "weight_grams"
    t.index ["discarded_at"], name: "index_variants_on_discarded_at"
    t.index ["options"], name: "index_variants_on_options", using: :gin
    t.index ["product_id", "position"], name: "index_variants_on_product_id_and_position"
    t.index ["product_id"], name: "index_variants_on_product_id"
    t.index ["sku"], name: "index_variants_on_sku", unique: true
    t.check_constraint "char_length(currency::text) = 3 AND currency::text = upper(currency::text)", name: "variants_currency_is_iso_code"
    t.check_constraint "compare_at_price_cents IS NULL OR compare_at_price_cents > price_cents", name: "variants_compare_at_exceeds_price"
    t.check_constraint "jsonb_typeof(options) = 'object'::text", name: "variants_options_is_object"
    t.check_constraint "price_cents > 0", name: "variants_price_is_positive"
    t.check_constraint "stock_quantity >= 0", name: "variants_stock_is_not_negative"
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.text "object"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "article_topics", "articles"
  add_foreign_key "article_topics", "topics"
  add_foreign_key "articles", "authors"
  add_foreign_key "articles", "topics", column: "primary_topic_id"
  add_foreign_key "audit_events", "users", column: "actor_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "variants"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "consent_records", "users"
  add_foreign_key "data_requests", "users"
  add_foreign_key "order_events", "orders", on_delete: :cascade
  add_foreign_key "order_events", "users", column: "actor_id"
  add_foreign_key "order_items", "orders", on_delete: :cascade
  add_foreign_key "order_items", "variants", on_delete: :nullify
  add_foreign_key "orders", "users"
  add_foreign_key "product_categories", "categories"
  add_foreign_key "product_categories", "products"
  add_foreign_key "products", "brands"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
  add_foreign_key "sources", "articles", on_delete: :cascade
  add_foreign_key "topics", "topics", column: "parent_id"
  add_foreign_key "variants", "products"
end
