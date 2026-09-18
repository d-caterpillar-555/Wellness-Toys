class Avo::Resources::Article < Avo::PunditResource
  self.icon = "tabler/outline/article"
  # self.avatar = {
  #   source: :avatar
  # }
  self.includes = [ :author, :primary_topic, :hero_image_attachment ]
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    # field :avatar, as: :avatar
    field :title, as: :text
    field :slug, as: :text
    field :kind, as: :text
    field :status, as: :text
    field :excerpt, as: :text
    field :body, as: :textarea
    field :author_id, as: :number
    field :primary_topic_id, as: :number
    field :reading_minutes, as: :number
    field :published_at, as: :date_time
    field :discarded_at, as: :date_time
    field :hero_image, as: :file
    field :slugs, as: :has_many
    field :author, as: :belongs_to
    field :primary_topic, as: :belongs_to
    field :article_topics, as: :has_many
    field :topics, as: :has_many, through: :article_topics
    field :sources, as: :has_many
  end
end
