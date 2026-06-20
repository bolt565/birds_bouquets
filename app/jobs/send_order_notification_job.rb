class SendOrderNotificationJob < ApplicationJob
  queue_as :mailers

  def perform(order_id)
    order = Order.find_by(id: order_id)
    unless order
      Rails.logger.warn("[SendOrderNotificationJob] Order #{order_id} not found")
      return
    end

    Rails.logger.info("[SendOrderNotificationJob] Sending notifications for order #{order.order_number}")
    OrderMailer.order_confirmation(order).deliver_now
    AdminMailer.new_order(order).deliver_now
  end
end
