class Avo::Resources::CartItem < Avo::PunditResource
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
    field :cart_id, as: :number
    field :variant_id, as: :number
    field :quantity, as: :number
    field :cart, as: :belongs_to
    field :variant, as: :belongs_to
  end
end
