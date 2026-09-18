class Avo::Resources::Variant < Avo::PunditResource
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
    field :product_id, as: :number
    field :name, as: :text
    field :sku, as: :text
    field :price_cents, as: :number
    field :compare_at_price_cents, as: :number
    field :currency, as: :text
    field :stock_quantity, as: :number
    field :weight_grams, as: :number
    field :active, as: :boolean
    field :options, as: :code
    field :position, as: :number
    field :discarded_at, as: :date_time
    field :product, as: :belongs_to
  end
end
