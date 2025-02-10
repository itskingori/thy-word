class Book < ApplicationRecord
  # Associations
  belongs_to :bible
  has_many :chapters, dependent: :restrict_with_exception
  has_many :headings, dependent: :restrict_with_exception
  has_many :segments, dependent: :restrict_with_exception
  has_many :verses, dependent: :restrict_with_exception

  # Validations
  validates :bible, presence: true
  validates :code, presence: true, length: { maximum: 3 }
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :title, presence: true
end
