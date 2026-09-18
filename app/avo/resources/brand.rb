class Avo::Resources::Brand < Avo::PunditResource
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
    field :country_code, as: :text
    field :website_url, as: :text
    field :discarded_at, as: :date_time
    field :slugs, as: :has_many
    field :products, as: :has_many
  end
end
