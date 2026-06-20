class OrderItem < ApplicationRecord
  include InputSanitizable

  belongs_to :order
  belongs_to :product, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price_cents, presence: true, numericality: { greater_than: 0 }
  validates :product_name, presence: true

  def line_total_cents
    quantity * unit_price_cents
  end

  def line_total_in_dollars
    format("$%.2f", line_total_cents / 100.0)
  end

  def unit_price_in_dollars
    format("$%.2f", unit_price_cents / 100.0)
  end
end
