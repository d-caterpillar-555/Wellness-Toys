class Avo::Resources::Product < Avo::PunditResource
  self.icon = "tabler/outline/package"
  # self.avatar = {
  #   source: :avatar
  # }
  self.includes = [ :brand, :cover_image_attachment ]
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    # field :avatar, as: :avatar
    field :name, as: :text
    field :slug, as: :text
    field :sku, as: :text
    field :subtitle, as: :text
    field :description, as: :textarea
    field :materials, as: :textarea
    field :care_instructions, as: :textarea
    field :safety_notes, as: :textarea
    field :dimensions, as: :text
    field :weight_grams, as: :number
    field :body_safe, as: :boolean
    field :status, as: :text
    field :published_at, as: :date_time
    field :brand_id, as: :number
    field :discarded_at, as: :date_time
    field :cover_image, as: :file
    field :slugs, as: :has_many
    field :brand, as: :belongs_to
    field :product_categories, as: :has_many
    field :categories, as: :has_many, through: :product_categories
    field :variants, as: :has_many
    field :reviews, as: :has_many
    field :faqs, as: :has_many
  end
end
