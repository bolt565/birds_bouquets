require "test_helper"

class AdminMailerTest < ActionMailer::TestCase
  def setup
    @order = orders(:pending_order)
    @user = users(:regular_user)
  end

  test "new_order sends to admin with order number" do
    mail = AdminMailer.new_order(@order)
    assert_includes mail.to.first, "birdsbouquets.com"
    assert_includes mail.subject, @order.order_number
  end

  test "new_signup sends to admin with user email" do
    mail = AdminMailer.new_signup(@user)
    assert_includes mail.to.first, "birdsbouquets.com"
    assert_includes mail.subject, @user.email
  end

  test "daily_digest sends summary to admin" do
    mail = AdminMailer.daily_digest(
      date: Date.new(2026, 6, 20),
      order_count: 5,
      revenue_cents: 49900,
      new_customers: 2
    )
    assert_includes mail.to.first, "birdsbouquets.com"
    assert_includes mail.subject, "Daily Digest"
    assert_includes mail.subject, "June 20, 2026"
  end
end
