class Fragment < ApplicationRecord
  # Associations
  belongs_to :bible
  belongs_to :book
  belongs_to :chapter
  belongs_to :heading
  belongs_to :segment
  belongs_to :verse, optional: true

  # Validations
  validates :bible, presence: true
  validates :book, presence: true
  validates :chapter, presence: true
  validates :content, presence: true
  validates :heading, presence: true
  validates :kind, presence: true
  validates :segment, presence: true
  validates :show_verse, inclusion: { in: [ true, false ] }

  # Enums
  enum :kind, { text: "text", note: "note", reference: "reference" }
end
