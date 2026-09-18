class Avo::Resources::ArticleTopic < Avo::PunditResource
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
    field :article_id, as: :number
    field :topic_id, as: :number
    field :article, as: :belongs_to
    field :topic, as: :belongs_to
  end
end
