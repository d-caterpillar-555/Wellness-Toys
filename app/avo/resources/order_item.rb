class Avo::Resources::OrderItem < Avo::PunditResource
  # self.icon = "tabler/outline/users"
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
    field :order_id, as: :number
    field :variant_id, as: :number
    field :product_name, as: :text
    field :variant_name, as: :text
    field :sku, as: :text
    field :unit_price_cents, as: :number
    field :quantity, as: :number
    field :line_total_cents, as: :number
    field :currency, as: :text
    field :order, as: :belongs_to
    field :variant, as: :belongs_to
  end
end
