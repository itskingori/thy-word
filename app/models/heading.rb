class Heading < ApplicationRecord
  # Associations
  belongs_to :bible
  belongs_to :book
  belongs_to :chapter

  # Validations
  validates :bible, presence: true
  validates :book, presence: true
  validates :chapter, presence: true
  validates :level, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :title, presence: true
end
