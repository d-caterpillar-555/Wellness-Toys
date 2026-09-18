class Avo::Resources::DataRequest < Avo::PunditResource
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
    field :user_id, as: :number
    field :kind, as: :text
    field :status, as: :text
    field :requested_at, as: :date_time
    field :completed_at, as: :date_time
    field :note, as: :textarea
    field :export, as: :file
    field :user, as: :belongs_to
  end
end
