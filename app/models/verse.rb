class Verse < ApplicationRecord
  # Associations
  belongs_to :bible
  belongs_to :book
  belongs_to :chapter
  has_many :fragments, dependent: :restrict_with_exception

  # Validations
  validates :bible, presence: true
  validates :book, presence: true
  validates :chapter, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
