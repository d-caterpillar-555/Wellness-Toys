class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    # Users.
    #
    # Devise is configured without :trackable on purpose. Trackable persists raw
    # IP addresses and sign-in timestamps, and on a site where visiting a
    # category page reveals health intent, storing raw IPs is exactly the kind of
    # unminimised data this project refuses. Security-relevant events are
    # recorded in audit_events with a hashed IP instead.
    create_table :users do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      t.string :name, null: false
      # Encrypted at the application layer. Stored as text because ciphertext is
      # longer than the plaintext and its length is not stable.
      t.text :phone

      t.string :role, null: false, default: "customer"

      # Both are set from the registration form and are a legal precondition of
      # having an account, not a preference. Enforced NOT NULL.
      t.datetime :age_confirmed_at, null: false
      t.datetime :terms_accepted_at, null: false

      t.datetime :discarded_at
      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :discarded_at
    add_check_constraint :users,
      "role IN ('customer', 'editor', 'admin')",
      name: "users_role_is_known"
    # A stored email must at least look like one. The database is not an email
    # validator, but it can refuse obvious rubbish.
    add_check_constraint :users,
      "email ~ '^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$'",
      name: "users_email_has_shape"

    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :label
      t.string :recipient, null: false
      # Street lines are encrypted. They are never searched, sorted or reported
      # on, so encryption costs nothing here. City, region, postal code and
      # country stay plaintext because shipping-zone logic will need to query
      # them, and they are far coarser than a street address.
      t.text :line1, null: false
      t.text :line2
      t.string :city, null: false
      t.string :region
      t.string :postal_code, null: false
      t.string :country_code, null: false
      t.boolean :default_shipping, null: false, default: false
      t.boolean :default_billing, null: false, default: false
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :addresses, :discarded_at
    add_index :addresses, :user_id, where: "default_shipping AND discarded_at IS NULL",
      unique: true, name: "addresses_one_default_shipping_per_user"
    add_index :addresses, :user_id, where: "default_billing AND discarded_at IS NULL",
      unique: true, name: "addresses_one_default_billing_per_user"
    add_check_constraint :addresses, "NOT (default_shipping AND default_billing)",
      name: "addresses_defaults_are_distinct"
    add_check_constraint :addresses,
      "char_length(country_code) = 2 AND country_code = upper(country_code)",
      name: "addresses_country_is_iso_code"
    add_check_constraint :addresses, "char_length(trim(recipient)) > 0",
      name: "addresses_recipient_is_present"

    # Consent records.
    #
    # Append-only. The trigger below refuses UPDATE and DELETE at the database
    # level, because a consent log that can be edited is not evidence of
    # anything. Withdrawing consent inserts a new row with revoked_at set rather
    # than modifying the original grant.
    #
    # Note there is no updated_at: a row's content never changes.
    create_table :consent_records do |t|
      # Identifies the subject of the consent. A user id when signed in, and an
      # opaque token for an anonymous visitor, so consent can be recorded before
      # an account exists.
      t.string :subject_token, null: false
      t.references :user, foreign_key: true

      t.string :kind, null: false
      t.datetime :granted_at, null: false
      t.datetime :revoked_at
      t.string :policy_version, null: false

      # Hashed, not raw. Enough to investigate a dispute, not enough to
      # identify a visitor from the log.
      t.string :ip_hash
      t.string :user_agent_hash

      t.datetime :created_at, null: false
    end

    add_index :consent_records, [ :subject_token, :kind ]
    add_index :consent_records, [ :user_id, :kind ]
    add_index :consent_records, :created_at
    add_index :consent_records, :kind, where: "revoked_at IS NULL",
      name: "consent_records_active_by_kind"
    add_check_constraint :consent_records,
      "kind IN ('functional', 'analytics', 'marketing')",
      name: "consent_records_kind_is_known"
    add_check_constraint :consent_records,
      "revoked_at IS NULL OR revoked_at >= granted_at",
      name: "consent_records_revoked_after_granted"
    add_check_constraint :consent_records,
      "char_length(policy_version) > 0",
      name: "consent_records_policy_version_present"

    reversible do |dir|
      dir.up do
        # safety_assured is justified, not waved through: consent_records was
        # created moments ago in this same transaction and has never held a row,
        # so creating a trigger on it cannot lock anything or rewrite data.
        # strong_migrations cannot inspect raw SQL, which is why it asks.
        safety_assured do
          execute <<~SQL
            CREATE FUNCTION consent_records_are_append_only() RETURNS trigger AS $$
            BEGIN
              RAISE EXCEPTION 'consent_records is append-only; insert a new row instead of %', TG_OP;
            END;
            $$ LANGUAGE plpgsql;
          SQL

          execute <<~SQL
            CREATE TRIGGER consent_records_no_update
            BEFORE UPDATE OR DELETE ON consent_records
            FOR EACH ROW EXECUTE FUNCTION consent_records_are_append_only();
          SQL
        end
      end

      dir.down do
        safety_assured do
          execute "DROP TRIGGER IF EXISTS consent_records_no_update ON consent_records"
          execute "DROP FUNCTION IF EXISTS consent_records_are_append_only()"
        end
      end
    end

    # Data requests.
    #
    # A real, working export and deletion workflow rather than a policy
    # paragraph. Every request has a lifecycle so it can be audited.
    create_table :data_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :requested_at, null: false
      t.datetime :completed_at
      t.text :note
      t.timestamps
    end

    add_index :data_requests, [ :user_id, :kind ]
    add_index :data_requests, :status
    add_check_constraint :data_requests,
      "kind IN ('export', 'delete')",
      name: "data_requests_kind_is_known"
    add_check_constraint :data_requests,
      "status IN ('pending', 'processing', 'completed', 'rejected')",
      name: "data_requests_status_is_known"
    add_check_constraint :data_requests,
      "status <> 'completed' OR completed_at IS NOT NULL",
      name: "data_requests_completed_are_timestamped"

    # Audit events.
    #
    # Who did what to which record, and when. Deliberately carries no PII: an
    # actor reference, an action name, a subject reference, and a hashed IP.
    # Enough to answer "was this record read, and by whom" without becoming a
    # second copy of the data it is auditing.
    create_table :audit_events do |t|
      t.references :actor, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :subject_type
      t.bigint :subject_id
      t.string :ip_hash
      t.jsonb :metadata, null: false, default: {}
      t.datetime :created_at, null: false
    end

    add_index :audit_events, [ :subject_type, :subject_id ]
    add_index :audit_events, [ :actor_id, :created_at ]
    add_index :audit_events, :action
    add_index :audit_events, :created_at
    add_index :audit_events, :metadata, using: :gin
    add_check_constraint :audit_events, "char_length(action) > 0",
      name: "audit_events_action_is_present"
    add_check_constraint :audit_events, "jsonb_typeof(metadata) = 'object'",
      name: "audit_events_metadata_is_object"
  end
end
