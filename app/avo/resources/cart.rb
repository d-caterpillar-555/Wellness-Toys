class Avo::Resources::Cart < Avo::PunditResource
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
    field :user_id, as: :number
    field :guest_token, as: :text
    field :user, as: :belongs_to
    field :cart_items, as: :has_many
    field :variants, as: :has_many, through: :cart_items
  end
end
