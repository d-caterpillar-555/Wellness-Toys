class Avo::Resources::Address < Avo::PunditResource
  self.icon = "tabler/outline/map-pin"
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
    field :user_id, as: :number
    field :label, as: :text
    field :recipient, as: :text
    field :line1, as: :textarea
    field :line2, as: :textarea
    field :city, as: :text
    field :region, as: :text
    field :postal_code, as: :text
    field :country_code, as: :text
    field :default_shipping, as: :boolean
    field :default_billing, as: :boolean
    field :discarded_at, as: :date_time
    field :user, as: :belongs_to
  end
end
