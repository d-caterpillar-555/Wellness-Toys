class Avo::Resources::Faq < Avo::PunditResource
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
    field :faqable_type, as: :text
    field :faqable_id, as: :number
    field :question, as: :text
    field :answer, as: :textarea
    field :position, as: :number
    field :discarded_at, as: :date_time
    field :faqable, as: :belongs_to, polymorphic_as: :faqable, types: [ Product ]
  end
end
