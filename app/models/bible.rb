class Bible < ApplicationRecord
  # Associations
  has_many :books, dependent: :restrict_with_exception
  has_many :chapters, dependent: :restrict_with_exception
  has_many :footnotes, dependent: :restrict_with_exception
  has_many :fragments, dependent: :restrict_with_exception
  has_many :headings, dependent: :restrict_with_exception
  has_many :segments, dependent: :restrict_with_exception
  has_many :verses, dependent: :restrict_with_exception

  # Validations
  validates :code, presence: true, length: { maximum: 3 }
  validates :name, presence: true
  validates :rights_holder_name, presence: true
  validates :rights_holder_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL" }
  validates :statement, presence: true
end
