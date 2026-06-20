class DailyOrderDigestJob < ApplicationJob
  queue_as :default

  def perform
    yesterday = Date.yesterday
    orders = Order.for_date(yesterday).paid_orders
    new_customers = User.where(created_at: yesterday.beginning_of_day..yesterday.end_of_day).count

    Rails.logger.info("[DailyOrderDigestJob] date=#{yesterday} orders=#{orders.count} revenue=#{orders.sum(:total_cents)}")

    AdminMailer.daily_digest(
      date: yesterday,
      order_count: orders.count,
      revenue_cents: orders.sum(:total_cents),
      new_customers: new_customers
    ).deliver_now
  end
end
