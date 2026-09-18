class ProductCategory < ApplicationRecord
  belongs_to :product
  belongs_to :category

  validates :product, presence: true
  validates :category, presence: true
  validates :category_id, uniqueness: { scope: :product_id }
end
