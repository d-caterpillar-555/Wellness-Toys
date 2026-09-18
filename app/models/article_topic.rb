class ArticleTopic < ApplicationRecord
  belongs_to :article
  belongs_to :topic

  validates :topic_id, uniqueness: { scope: :article_id }
end
