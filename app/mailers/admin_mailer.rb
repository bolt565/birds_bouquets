class AdminMailer < ApplicationMailer
  ADMIN_EMAIL = ENV.fetch("ADMIN_EMAIL", "admin@birdsbouquets.com")

  def new_order(order)
    @order = order
    mail(to: ADMIN_EMAIL, subject: "New Order #{order.order_number} — #{order.total_in_dollars}")
  end

  def new_signup(user)
    @user = user
    mail(to: ADMIN_EMAIL, subject: "New Signup: #{user.email}")
  end

  def daily_digest(date:, order_count:, revenue_cents:, new_customers:)
    @date = date
    @order_count = order_count
    @revenue_cents = revenue_cents
    @new_customers = new_customers
    mail(to: ADMIN_EMAIL, subject: "Daily Digest — #{date.strftime('%B %d, %Y')}")
  end
end
