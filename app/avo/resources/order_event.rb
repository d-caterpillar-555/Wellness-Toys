class Avo::Resources::OrderEvent < Avo::PunditResource
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
    field :order_id, as: :number
    field :actor_id, as: :number
    field :kind, as: :text
    field :note, as: :textarea
    field :to_status, as: :text
    field :order, as: :belongs_to
    field :actor, as: :belongs_to
  end
end
