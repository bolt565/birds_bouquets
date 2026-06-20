require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  def setup
    @order = orders(:pending_order)
  end

  test "order_confirmation has correct recipient and subject" do
    mail = OrderMailer.order_confirmation(@order)
    assert_equal [@order.email], mail.to
    assert_includes mail.subject, @order.order_number
    assert_includes mail.subject, "Confirmed"
  end

  test "order_confirmation sent from correct address" do
    mail = OrderMailer.order_confirmation(@order)
    assert_includes mail.from.first, "birdsbouquets.com"
  end

  test "order_shipped has tracking info" do
    @order.update!(tracking_number: "USPS1234567890", status: "shipped", shipped_at: Time.current)
    mail = OrderMailer.order_shipped(@order)
    assert_equal [@order.email], mail.to
    assert_includes mail.subject, "Shipped"
    assert_includes mail.subject, @order.order_number
  end

  test "order_delivered addresses customer" do
    mail = OrderMailer.order_delivered(@order)
    assert_equal [@order.email], mail.to
    assert_includes mail.subject, "Delivered"
  end
end
