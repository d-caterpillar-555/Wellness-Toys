class Avo::Resources::Topic < Avo::PunditResource
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
    field :name, as: :text
    field :slug, as: :text
    field :description, as: :textarea
    field :parent_id, as: :number
    field :position, as: :number
    field :discarded_at, as: :date_time
    field :slugs, as: :has_many
    field :parent, as: :belongs_to
    field :children, as: :has_many
    field :article_topics, as: :has_many
    field :articles, as: :has_many, through: :article_topics
  end
end
