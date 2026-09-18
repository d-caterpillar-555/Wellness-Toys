class Avo::Resources::Source < Avo::PunditResource
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
    field :title, as: :text
    field :url, as: :text
    field :publisher, as: :text
    field :published_on, as: :date
    field :position, as: :number
    field :article, as: :belongs_to
  end
end
