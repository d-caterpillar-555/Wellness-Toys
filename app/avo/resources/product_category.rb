class Avo::Resources::ProductCategory < Avo::PunditResource
  # Edited through the parent record (a product or an article), never on its own.
  self.visible_on_sidebar = false

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
    field :category_id, as: :number
    field :position, as: :number
    field :product, as: :belongs_to
    field :category, as: :belongs_to
  end
end
