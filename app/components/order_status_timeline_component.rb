class OrderStatusTimelineComponent < ViewComponent::Base
  STEPS = [
    { key: "pending",         label: "Order Placed" },
    { key: "paid",            label: "Payment Confirmed" },
    { key: "processing",      label: "Being Prepared" },
    { key: "shipped",         label: "Shipped" },
    { key: "delivered",       label: "Delivered" }
  ].freeze

  STATUS_POSITION = {
    "pending" => 0, "payment_pending" => 0, "paid" => 1,
    "processing" => 2, "shipped" => 3, "delivered" => 4,
    "cancelled" => -1, "refunded" => -1
  }.freeze

  def initialize(order:)
    @order = order
    @current_position = STATUS_POSITION.fetch(order.status, 0)
    @cancelled = %w[cancelled refunded].include?(order.status)
  end

  private

  attr_reader :order, :current_position, :cancelled

  def step_state(index)
    return :cancelled if cancelled
    if index < current_position then :completed
    elsif index == current_position then :active
    else :upcoming
    end
  end
end
