class Book < ApplicationRecord
  # Associations
  belongs_to :bible

  # Validations
  validates :bible, presence: true
  validates :code, presence: true, length: { maximum: 3 }
  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :title, presence: true
end
