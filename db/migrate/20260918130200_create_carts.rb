class CreateCarts < ActiveRecord::Migration[8.1]
  def change
    # A cart belongs to exactly one of: a signed-in user, or an anonymous
    # visitor holding a guest token. Never both, never neither. That invariant
    # is a CHECK constraint rather than a validation, because a cart with no
    # owner is orphaned data and a cart with two owners is a security question
    # nobody wants to answer later.
    create_table :carts do |t|
      t.references :user, foreign_key: true
      t.string :guest_token
      t.timestamps
    end

    add_index :carts, :guest_token, unique: true, where: "guest_token IS NOT NULL"
    add_index :carts, :user_id, unique: true, where: "user_id IS NOT NULL",
      name: "carts_one_per_user"
    add_check_constraint :carts,
      "(user_id IS NOT NULL) <> (guest_token IS NOT NULL)",
      name: "carts_have_exactly_one_owner"

    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :variant, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.timestamps
    end

    # One row per variant per cart. Adding an existing variant increments the
    # quantity of the row that is already there rather than creating a second
    # line, and this index is what makes that structurally true.
    add_index :cart_items, [ :cart_id, :variant_id ], unique: true
    add_check_constraint :cart_items, "quantity > 0", name: "cart_items_quantity_is_positive"
    # A cart line that needs more than 100 of one variant is not a customer.
    add_check_constraint :cart_items, "quantity <= 100", name: "cart_items_quantity_is_sane"
  end
end
