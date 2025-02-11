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

  # Constants
  HEADER_STYLES_INTRODUCTORY = [ "h", "toc2", "toc1", "mt1" ]
  HEADER_STYLES_SECTIONS_MAJOR = { ms: 0, ms1: 1, ms2: 2, ms3: 3, ms4: 4 }
  HEADER_STYLES_SECTIONS_MINOR = { s1: 1, s2: 2, s3: 3, s4: 4 }
end
