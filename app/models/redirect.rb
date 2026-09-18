class Redirect < ApplicationRecord
  include Discard::Model

  STATUS_CODES = [ 301, 302, 307, 308 ].freeze

  validates :from_path, presence: true, uniqueness: true
  validates :to_path, presence: true
  # A path, not a URL and not a pattern: it starts with a slash, carries no
  # whitespace, and nothing follows the end of it.
  validates :from_path, :to_path,
    format: { with: %r{\A/[^\s]*\z}, message: "must be a path starting with /" }
  validates :status_code, inclusion: { in: STATUS_CODES }
  validate :paths_differ

  def self.resolve(path)
    kept.find_by(from_path: path)
  end

  def permanent?
    status_code == 301
  end

  private
    def paths_differ
      if from_path.present? && from_path == to_path
        errors.add(:to_path, "must differ from the path it redirects from")
      end
    end
end
