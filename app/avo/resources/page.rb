class Avo::Resources::Page < Avo::PunditResource
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
    field :slug, as: :text
    field :title, as: :text
    field :subtitle, as: :text
    field :body, as: :textarea
    field :meta_title, as: :text
    field :meta_description, as: :text
    field :show_in_footer, as: :boolean
    field :position, as: :number
    field :published_at, as: :date_time
    field :discarded_at, as: :date_time
  end
end
