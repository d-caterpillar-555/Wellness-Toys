class Faq < ApplicationRecord
  include Discard::Model

  belongs_to :faqable, polymorphic: true

  validates :question, :answer, presence: true

  scope :ordered, -> { order(:position) }
  scope :kept_active, -> { kept }

  # A FAQ is addressed by its id: the question wording can change without
  # breaking an anchor, which a slug built from the question would not survive.
  def to_param
    id
  end
end
