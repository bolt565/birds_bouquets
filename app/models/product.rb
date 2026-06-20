class Product < ApplicationRecord
  include InputSanitizable

  belongs_to :category, optional: true
  has_many :product_images, -> { order(:position) }, dependent: :destroy
  has_many :order_items

  validates :name, :description, presence: true
  validates :price_cents, presence: true, numericality: { greater_than: 0 }
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }

  before_validation :generate_slug, if: -> { slug.blank? }

  scope :in_stock, -> { where(in_stock: true) }
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :ordered, -> { order(:position, :name) }
  scope :published, -> { in_stock }

  def to_param
    slug
  end

  def price_in_dollars
    format("$%.2f", price_cents / 100.0)
  end

  def compare_at_price_in_dollars
    return nil unless compare_at_price_cents
    format("$%.2f", compare_at_price_cents / 100.0)
  end

  def on_sale?
    compare_at_price_cents.present? && compare_at_price_cents > price_cents
  end

  def primary_image
    product_images.first
  end

  def sold_out?
    !in_stock?
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
