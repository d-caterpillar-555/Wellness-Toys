class CreateEducationAndContent < ActiveRecord::Migration[8.1]
  def change
    # --- Reviews -----------------------------------------------------------
    #
    # One review per customer per product, enforced structurally. A rating
    # outside 1..5 is refused by the database, not by a validation that a
    # console session can bypass.
    create_table :reviews do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.integer :rating, null: false
      t.string :title
      t.text :body

      t.string :status, null: false, default: "pending"
      # Set from order history at write time, never trusted from a form.
      t.boolean :verified_purchase, null: false, default: false

      t.datetime :published_at
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :reviews, [ :product_id, :user_id ], unique: true
    add_index :reviews, [ :product_id, :status ]
    add_index :reviews, :discarded_at
    add_check_constraint :reviews, "rating BETWEEN 1 AND 5", name: "reviews_rating_in_range"
    add_check_constraint :reviews,
      "status IN ('pending', 'approved', 'rejected')",
      name: "reviews_status_is_known"
    add_check_constraint :reviews,
      "status <> 'approved' OR published_at IS NOT NULL",
      name: "reviews_approved_are_published"

    # --- Newsletter --------------------------------------------------------
    create_table :newsletter_subscribers do |t|
      t.string :email, null: false
      t.datetime :consented_at, null: false
      t.datetime :unsubscribed_at
      t.string :source
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :newsletter_subscribers, :email, unique: true
    add_index :newsletter_subscribers, :discarded_at
    add_check_constraint :newsletter_subscribers,
      "unsubscribed_at IS NULL OR unsubscribed_at >= consented_at",
      name: "newsletter_unsubscribed_after_consented"

    # --- Education ---------------------------------------------------------
    #
    # Topics are the pillar hubs. Hierarchical, unlike categories, because
    # education genuinely nests ("Sexual health" contains "Contraception").
    create_table :topics do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.references :parent, foreign_key: { to_table: :topics }
      t.integer :position, null: false, default: 0
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :topics, :slug, unique: true
    add_index :topics, [ :parent_id, :position ]
    add_index :topics, :discarded_at
    add_check_constraint :topics, "parent_id IS NULL OR parent_id <> id",
      name: "topics_parent_not_self"

    # Authors carry credentials. The column is nullable and there is no default,
    # because an empty credential is honest and an invented one is not.
    create_table :authors do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :credentials
      t.text :bio
      t.boolean :is_clinician, null: false, default: false
      t.string :website_url
      t.integer :position, null: false, default: 0
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :authors, :slug, unique: true
    add_index :authors, :discarded_at

    create_table :articles do |t|
      t.string :title, null: false
      t.string :slug, null: false
      # guide | pillar | glossary | post. A post is a kind of article reachable
      # at /blog, not a separate model.
      t.string :kind, null: false, default: "guide"
      t.string :status, null: false, default: "draft"

      t.string :excerpt
      t.text :body

      t.references :author, foreign_key: true
      t.references :primary_topic, foreign_key: { to_table: :topics }

      t.integer :reading_minutes
      t.datetime :published_at
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :articles, :slug, unique: true
    add_index :articles, :kind
    add_index :articles, :status
    add_index :articles, :published_at
    add_index :articles, :discarded_at
    add_index :articles, :title, opclass: :gin_trgm_ops, using: :gin
    add_check_constraint :articles,
      "kind IN ('guide', 'pillar', 'glossary', 'post')",
      name: "articles_kind_is_known"
    add_check_constraint :articles,
      "status IN ('draft', 'published', 'archived')",
      name: "articles_status_is_known"
    add_check_constraint :articles,
      "status <> 'published' OR published_at IS NOT NULL",
      name: "articles_published_are_timestamped"
    add_check_constraint :articles,
      "reading_minutes IS NULL OR reading_minutes > 0",
      name: "articles_reading_minutes_is_positive"

    create_table :article_topics do |t|
      t.references :article, null: false, foreign_key: true
      t.references :topic, null: false, foreign_key: true
      t.timestamps
    end

    add_index :article_topics, [ :article_id, :topic_id ], unique: true

    # Sources power the evidence rail. A source with no URL or no publisher is
    # not a citation, so both are required at the database level.
    create_table :sources do |t|
      t.references :article, null: false, foreign_key: { on_delete: :cascade }
      t.string :title, null: false
      t.string :url, null: false
      t.string :publisher, null: false
      t.date :published_on
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    add_index :sources, [ :article_id, :position ]
    add_check_constraint :sources, "url ~ '^https?://'", name: "sources_url_is_absolute"
    add_check_constraint :sources, "char_length(trim(title)) > 0", name: "sources_title_present"
    add_check_constraint :sources, "char_length(trim(publisher)) > 0",
      name: "sources_publisher_present"

    # --- FAQs --------------------------------------------------------------
    #
    # Polymorphic: a question can hang off a Product or a Page. Both columns are
    # NOT NULL together because a FAQ attached to nothing is unreachable.
    create_table :faqs do |t|
      t.references :faqable, polymorphic: true, null: false
      t.string :question, null: false
      t.text :answer, null: false
      t.integer :position, null: false, default: 0
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :faqs, [ :faqable_type, :faqable_id, :position ]
    add_index :faqs, :discarded_at
    add_check_constraint :faqs, "char_length(trim(question)) > 0", name: "faqs_question_present"
    add_check_constraint :faqs, "char_length(trim(answer)) > 0", name: "faqs_answer_present"

    # --- Redirects ---------------------------------------------------------
    #
    # Slug changes are normal; broken inbound links are not. A redirect row
    # keeps an old path resolving after a rename.
    create_table :redirects do |t|
      t.string :from_path, null: false
      t.string :to_path, null: false
      t.integer :status_code, null: false, default: 301
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :redirects, :from_path, unique: true
    add_index :redirects, :discarded_at
    add_check_constraint :redirects,
      "status_code IN (301, 302, 307, 308)",
      name: "redirects_status_is_permanent_or_temporary"
    add_check_constraint :redirects,
      "from_path ~ '^/' AND to_path ~ '^/'",
      name: "redirects_paths_are_absolute"
    add_check_constraint :redirects, "from_path <> to_path",
      name: "redirects_do_not_loop_to_self"
  end
end
