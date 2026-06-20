class Admin::DashboardController < Admin::BaseController
  def index
    today = Date.current
    yesterday = today - 1
    week_ago = today - 7

    @today_orders = Order.for_date(today)
    @today_revenue = @today_orders.paid_orders.sum(:total_cents)
    @today_order_count = @today_orders.count

    @pending_orders = Order.where(status: %w[paid processing]).count
    @out_of_stock_count = Product.where(in_stock: false).count
    @new_customers_this_week = User.where(created_at: week_ago.beginning_of_day..Time.current).count

    @last_7_days_revenue = (0..6).map do |i|
      date = today - i
      revenue = Order.for_date(date).paid_orders.sum(:total_cents)
      { date: date.strftime("%a %m/%d"), revenue_cents: revenue }
    end.reverse

    @recent_orders = Order.recent.limit(10)
  end
end
