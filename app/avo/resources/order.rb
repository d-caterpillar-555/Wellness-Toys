class Avo::Resources::Order < Avo::PunditResource
  self.icon = "tabler/outline/shopping-cart"
  # self.avatar = {
  #   source: :avatar
  # }
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    # field :avatar, as: :avatar
    field :number, as: :text
    # public_token and checkout_token are deliberately absent: one is the guest's
    # access credential, the other is a double-submit key. Neither belongs on a
    # screen and neither is editable.
    field :user_id, as: :number
    field :status, as: :text
    field :payment_status, as: :text
    field :currency, as: :text
    field :subtotal_cents, as: :number
    field :shipping_cents, as: :number
    field :tax_cents, as: :number
    field :total_cents, as: :number
    field :email, as: :text
    field :ship_to_recipient, as: :text
    field :ship_to_line1, as: :text
    field :ship_to_line2, as: :text
    field :ship_to_city, as: :text
    field :ship_to_region, as: :text
    field :ship_to_postal_code, as: :text
    field :ship_to_country_code, as: :text
    field :note, as: :textarea
    field :placed_at, as: :date_time
    field :discarded_at, as: :date_time
    field :user, as: :belongs_to
    field :order_items, as: :has_many
    field :order_events, as: :has_many
  end
end
