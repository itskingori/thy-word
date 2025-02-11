class Segment < ApplicationRecord
  # Associations
  belongs_to :bible
  belongs_to :book
  belongs_to :chapter
  belongs_to :heading
  has_many :fragments, dependent: :restrict_with_exception

  # Validations
  validates :bible, presence: true
  validates :book, presence: true
  validates :chapter, presence: true
  validates :heading, presence: true
  validates :style, presence: true
end
