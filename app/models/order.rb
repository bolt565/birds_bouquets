class Order < ApplicationRecord
  include InputSanitizable

  class InvalidTransition < StandardError; end

  STATUSES = %w[pending payment_pending paid processing shipped delivered cancelled refunded].freeze

  VALID_TRANSITIONS = {
    "pending" => %w[payment_pending],
    "payment_pending" => %w[paid cancelled],
    "paid" => %w[processing refunded],
    "processing" => %w[shipped],
    "shipped" => %w[delivered],
    "delivered" => [],
    "cancelled" => [],
    "refunded" => []
  }.freeze

  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy

  validates :order_number, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subtotal_cents, :total_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_name, :shipping_line1, :shipping_city, :shipping_state, :shipping_zip, :shipping_country, presence: true

  before_validation :set_defaults, on: :create

  scope :by_status, ->(status) { where(status: status) }
  scope :paid_orders, -> { where(status: %w[paid processing shipped delivered]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_date, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }

  def transition_to!(new_status)
    new_status = new_status.to_s
    allowed = VALID_TRANSITIONS[status] || []

    unless allowed.include?(new_status)
      raise InvalidTransition, "Cannot transition from '#{status}' to '#{new_status}'"
    end

    if new_status == "shipped" && tracking_number.blank?
      raise InvalidTransition, "Tracking number is required before marking as shipped"
    end

    self.status = new_status
    self.paid_at = Time.current if new_status == "paid"
    self.shipped_at = Time.current if new_status == "shipped"
    self.delivered_at = Time.current if new_status == "delivered"
    self.cancelled_at = Time.current if new_status == "cancelled"
    save!
  end

  def total_in_dollars
    format("$%.2f", total_cents / 100.0)
  end

  def subtotal_in_dollars
    format("$%.2f", subtotal_cents / 100.0)
  end

  def customer_name
    user&.name || shipping_name
  end

  def next_valid_statuses
    VALID_TRANSITIONS[status] || []
  end

  def self.generate_order_number
    year = Time.current.year
    prefix = "BB-#{year}-"
    loop do
      sequence = rand(1..99999)
      candidate = "#{prefix}#{sequence.to_s.rjust(5, '0')}"
      break candidate unless exists?(order_number: candidate)
    end
  end

  private

  def set_defaults
    self.order_number ||= self.class.generate_order_number
    self.status ||= "pending"
    self.shipping_cents ||= 0
    self.tax_cents ||= 0
    self.shipping_country ||= "US"
  end
end
