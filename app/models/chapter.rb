class Chapter < ApplicationRecord
  # Associations
  belongs_to :bible
  belongs_to :book

  # Validations
  validates :bible, presence: true
  validates :book, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
