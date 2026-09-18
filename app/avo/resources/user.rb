class Avo::Resources::User < Avo::PunditResource
  self.icon = "tabler/outline/users"
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
    field :name, as: :text
    field :phone, as: :textarea
    field :role, as: :text
    field :age_confirmed_at, as: :date_time
    field :terms_accepted_at, as: :date_time
    field :discarded_at, as: :date_time
    field :orders, as: :has_many
    field :addresses, as: :has_many
    field :reviews, as: :has_many
    field :consent_records, as: :has_many
    field :data_requests, as: :has_many
    field :cart, as: :has_one
  end
end
