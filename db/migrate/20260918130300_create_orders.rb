class CreateOrders < ActiveRecord::Migration[8.1]
  # Orders.
  #
  # Three identifiers, each doing one job:
  #
  #   number          Human-facing reference, e.g. WT-2026-000123. Shown to the
  #                   customer and quoted in support email. NOT a credential:
  #                   it is sequential and guessable by design.
  #   public_token    The access credential for a guest order. Random, opaque,
  #                   and the only thing that grants access to /orders/:token.
  #                   Keeping these separate is the difference between "you can
  #                   read your order" and "you can enumerate everyone's".
  #   checkout_token  Client-supplied, single-use, unique-indexed. This is what
  #                   makes order creation idempotent against a double submit.
  #
  # Address is snapshotted onto the order rather than referenced. An order must
  # never change because someone edited their saved address afterwards, and it
  # must survive that address being deleted.
  def change
    create_table :orders do |t|
      t.string :number, null: false
      t.string :public_token, null: false
      t.string :checkout_token, null: false
      t.references :user, foreign_key: true

      t.string :status, null: false, default: "pending"
      # Payment-free for v1, but the column exists now so that adding a provider
      # is a code change rather than a migration on a table full of real orders.
      t.string :payment_status, null: false, default: "awaiting_invoice"

      t.string :currency, null: false, default: "USD"
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :shipping_cents, null: false, default: 0
      t.integer :tax_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0

      t.string :email, null: false
      t.string :ship_to_recipient, null: false
      t.string :ship_to_line1, null: false
      t.string :ship_to_line2
      t.string :ship_to_city, null: false
      t.string :ship_to_region
      t.string :ship_to_postal_code, null: false
      t.string :ship_to_country_code, null: false

      # Encrypted. A note on an order in this category routinely describes a
      # health situation, and it is never queried.
      t.text :note

      t.datetime :placed_at
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :orders, :number, unique: true
    add_index :orders, :public_token, unique: true
    add_index :orders, :checkout_token, unique: true
    add_index :orders, [ :user_id, :created_at ]
    add_index :orders, :status
    add_index :orders, :placed_at
    add_index :orders, :discarded_at

    add_check_constraint :orders, "subtotal_cents >= 0", name: "orders_subtotal_not_negative"
    add_check_constraint :orders, "shipping_cents >= 0", name: "orders_shipping_not_negative"
    add_check_constraint :orders, "tax_cents >= 0", name: "orders_tax_not_negative"
    add_check_constraint :orders, "total_cents >= 0", name: "orders_total_not_negative"
    add_check_constraint :orders,
      "status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')",
      name: "orders_status_is_known"
    add_check_constraint :orders,
      "payment_status IN ('awaiting_invoice', 'unpaid', 'paid', 'refunded', 'failed')",
      name: "orders_payment_status_is_known"
    add_check_constraint :orders,
      "char_length(currency) = 3 AND currency = upper(currency)",
      name: "orders_currency_is_iso_code"
    add_check_constraint :orders,
      "char_length(public_token) >= 22",
      name: "orders_public_token_is_long_enough"
    add_check_constraint :orders,
      "char_length(ship_to_country_code) = 2 AND ship_to_country_code = upper(ship_to_country_code)",
      name: "orders_country_is_iso_code"
    add_check_constraint :orders,
      "status <> 'confirmed' OR placed_at IS NOT NULL",
      name: "orders_confirmed_are_placed"

    # Order items.
    #
    # Snapshot rows, not references. product_name, variant_name and sku are
    # captured at purchase time so a receipt from two years ago still says what
    # was actually bought, even if the product was renamed, repriced, or
    # deleted. The variant reference is kept, but nullable, purely so an admin
    # can jump to the current product; it is never the source of what was
    # ordered.
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: { on_delete: :cascade }
      t.references :variant, foreign_key: { on_delete: :nullify }

      t.string :product_name, null: false
      t.string :variant_name, null: false
      t.string :sku, null: false
      t.integer :unit_price_cents, null: false
      t.integer :quantity, null: false
      t.integer :line_total_cents, null: false
      t.string :currency, null: false, default: "USD"
      t.timestamps
    end

    # No explicit index on order_id here: t.references above already created
    # index_order_items_on_order_id, and adding it again is a duplicate.
    add_check_constraint :order_items, "quantity > 0", name: "order_items_quantity_is_positive"
    add_check_constraint :order_items, "unit_price_cents >= 0",
      name: "order_items_unit_price_not_negative"
    add_check_constraint :order_items, "line_total_cents >= 0",
      name: "order_items_line_total_not_negative"
    # The line total must actually be the arithmetic result. If these ever
    # disagree, the receipt is lying.
    add_check_constraint :order_items,
      "line_total_cents = unit_price_cents * quantity",
      name: "order_items_line_total_is_consistent"

    # Order events.
    #
    # State as records rather than a status boolean. Every transition and note
    # carries who, when and why, which a mutable status column cannot.
    create_table :order_events do |t|
      t.references :order, null: false, foreign_key: { on_delete: :cascade }
      t.references :actor, foreign_key: { to_table: :users }
      t.string :kind, null: false
      t.text :note
      # The status as it stood after this event, so the history can be replayed
      # without inferring order from timestamps.
      t.string :to_status
      t.datetime :created_at, null: false
    end

    add_index :order_events, [ :order_id, :created_at ]
    add_index :order_events, :kind
    add_check_constraint :order_events, "char_length(kind) > 0",
      name: "order_events_kind_is_present"
    add_check_constraint :order_events,
      "to_status IS NULL OR to_status IN ('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled')",
      name: "order_events_status_is_known"
  end
end
