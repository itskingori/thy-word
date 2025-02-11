class Chapter < ApplicationRecord
  # Associations
  belongs_to :bible
  belongs_to :book
  has_many :footnotes, dependent: :restrict_with_exception
  has_many :fragments, dependent: :restrict_with_exception
  has_many :headings, dependent: :restrict_with_exception
  has_many :segments, dependent: :restrict_with_exception
  has_many :verses, dependent: :restrict_with_exception

  # Validations
  validates :bible, presence: true
  validates :book, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
