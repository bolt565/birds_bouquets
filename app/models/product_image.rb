class ProductImage < ApplicationRecord
  include InputSanitizable

  belongs_to :product
  has_one_attached :image

  validates :alt_text, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position) }
end
