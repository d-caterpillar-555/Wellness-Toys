class Avo::Resources::Author < Avo::PunditResource
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
    field :credentials, as: :text
    field :bio, as: :textarea
    field :is_clinician, as: :boolean
    field :website_url, as: :text
    field :position, as: :number
    field :discarded_at, as: :date_time
    field :slugs, as: :has_many
    field :articles, as: :has_many
  end
end
