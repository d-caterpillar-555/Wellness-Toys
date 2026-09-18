class Avo::Resources::ConsentRecord < Avo::PunditResource
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
    field :subject_token, as: :text
    field :user_id, as: :number
    field :kind, as: :text
    field :granted_at, as: :date_time
    field :revoked_at, as: :date_time
    field :policy_version, as: :text
    field :ip_hash, as: :text
    field :user_agent_hash, as: :text
    field :user, as: :belongs_to
  end
end
