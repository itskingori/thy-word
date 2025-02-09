class Bible < ApplicationRecord
  # Validations
  validates :code, presence: true, length: { maximum: 3 }
  validates :name, presence: true
  validates :rights_holder_name, presence: true
  validates :rights_holder_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "must be a valid URL" }
  validates :statement, presence: true
end
