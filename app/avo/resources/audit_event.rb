class Avo::Resources::AuditEvent < Avo::PunditResource
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
    field :actor_id, as: :number
    field :action, as: :text
    field :subject_type, as: :text
    field :subject_id, as: :number
    field :ip_hash, as: :text
    field :metadata, as: :code
    field :actor, as: :belongs_to
    field :subject, as: :belongs_to, polymorphic_as: :subject, types: [] # Types weren't computed correctly. Please configure them.
  end
end
