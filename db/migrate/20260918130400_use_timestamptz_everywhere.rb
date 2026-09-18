class UseTimestamptzEverywhere < ActiveRecord::Migration[8.1]
  # Converts every timestamp column created so far to timestamptz.
  #
  # The initializer added alongside this migration only affects columns created
  # from now on, so the existing ones are converted here.
  #
  # The USING clause is the important part. Existing values were written as UTC
  # by Active Record, so `col AT TIME ZONE 'UTC'` reinterprets each value as the
  # instant it actually represents. Without it, PostgreSQL would assume the
  # session timezone and silently shift every row.
  #
  # safety_assured is justified: every table here except `pages` is empty, and
  # `pages` holds ten seed rows. There is no data volume to rewrite and no
  # concurrent traffic to block. This would not be a safe migration to run
  # against a populated production table, and it is not intended to be.
  COLUMNS = {
    addresses: %w[created_at updated_at discarded_at],
    audit_events: %w[created_at],
    brands: %w[created_at updated_at discarded_at],
    cart_items: %w[created_at updated_at],
    carts: %w[created_at updated_at],
    categories: %w[created_at updated_at discarded_at],
    consent_records: %w[created_at granted_at revoked_at],
    data_requests: %w[created_at updated_at requested_at completed_at],
    order_events: %w[created_at],
    order_items: %w[created_at updated_at],
    orders: %w[created_at updated_at discarded_at placed_at],
    pages: %w[created_at updated_at discarded_at published_at],
    product_categories: %w[created_at updated_at],
    products: %w[created_at updated_at discarded_at published_at],
    users: %w[
      created_at updated_at discarded_at
      age_confirmed_at terms_accepted_at
      remember_created_at reset_password_sent_at
    ],
    variants: %w[created_at updated_at discarded_at]
  }.freeze

  def up
    safety_assured do
      COLUMNS.each do |table, columns|
        columns.each do |column|
          change_column table, column, :timestamptz,
            using: "#{column} AT TIME ZONE 'UTC'"
        end
      end
    end
  end

  def down
    safety_assured do
      COLUMNS.each do |table, columns|
        columns.each do |column|
          change_column table, column, :timestamp, using: "#{column} AT TIME ZONE 'UTC'"
        end
      end
    end
  end
end
