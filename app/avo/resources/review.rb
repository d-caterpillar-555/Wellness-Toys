class Avo::Resources::Review < Avo::PunditResource
  self.icon = "tabler/outline/star"
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
    field :user_id, as: :number
    field :rating, as: :number
    field :title, as: :text
    field :body, as: :textarea
    field :status, as: :text
    field :verified_purchase, as: :boolean
    field :published_at, as: :date_time
    field :discarded_at, as: :date_time
    field :product, as: :belongs_to
    field :user, as: :belongs_to
  end
end
