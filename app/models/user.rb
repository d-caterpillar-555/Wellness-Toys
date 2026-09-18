class User < ApplicationRecord
  include Discard::Model

  ROLES = %w[customer editor admin].freeze

  # Devise is configured without :trackable on purpose. Trackable persists the
  # raw IP of every sign-in, and on a site where reading one page reveals health
  # intent, a stored IP is exactly the data this project refuses to keep.
  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :validatable, :timeoutable

  encrypts :phone

  has_many :orders, dependent: :nullify
  has_many :addresses, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :consent_records, dependent: :nullify
  has_many :data_requests, dependent: :destroy
  has_one :cart, dependent: :destroy

  validates :name, presence: true
  validates :age_confirmed_at, presence: true
  validates :terms_accepted_at, presence: true
  validates :role, inclusion: { in: ROLES }

  scope :active, -> { kept }
  scope :alphabetical, -> { order(:name) }
  scope :customers, -> { where(role: "customer") }
  scope :editors, -> { where(role: "editor") }
  scope :admins, -> { where(role: "admin") }

  def customer?
    role == "customer"
  end

  def editor?
    role == "editor"
  end

  def admin?
    role == "admin"
  end

  def staff?
    editor? || admin?
  end

  def display_name
    name.presence || email.split("@").first
  end

  # Erases the account for a deletion request without destroying the order
  # history that tax and consumer law require us to keep. Idempotent: rerunning
  # rewrites the same tombstone and leaves an already-discarded row alone.
  #
  # name is NOT NULL, so it clears to an empty string rather than nil, and email
  # becomes a reserved example.invalid address that keeps the unique index
  # satisfied without being deliverable. update_columns is deliberate: the name
  # presence validation would otherwise reject the cleared row.
  def anonymise!
    transaction do
      update_columns(email: "deleted-#{id}@example.invalid", name: "", phone: nil)
      discard
    end
  end
end
