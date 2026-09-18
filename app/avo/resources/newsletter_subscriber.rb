class Avo::Resources::NewsletterSubscriber < Avo::PunditResource
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
    field :email, as: :text
    field :consented_at, as: :date_time
    field :unsubscribed_at, as: :date_time
    field :source, as: :text
    field :discarded_at, as: :date_time
  end
end
