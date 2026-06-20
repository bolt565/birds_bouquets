require "test_helper"

class OrderTest < ActiveSupport::TestCase
  def setup
    @pending = orders(:pending_order)
    @paid = orders(:paid_order)
    @shipped = orders(:shipped_order)
  end

  test "generate_order_number returns unique BB-YYYY-##### format" do
    num = Order.generate_order_number
    assert_match(/\ABB-\d{4}-\d{5}\z/, num)
  end

  test "generate_order_number is unique" do
    numbers = 5.times.map { Order.generate_order_number }
    assert_equal numbers.uniq.size, numbers.size
  end

  test "valid transition pending to payment_pending" do
    @pending.transition_to!(:payment_pending)
    assert_equal "payment_pending", @pending.status
  end

  test "invalid transition pending to shipped raises error" do
    assert_raises(Order::InvalidTransition) do
      @pending.transition_to!(:shipped)
    end
  end

  test "invalid transition pending to delivered raises error" do
    assert_raises(Order::InvalidTransition) do
      @pending.transition_to!(:delivered)
    end
  end

  test "shipped transition requires tracking number" do
    @paid.transition_to!(:processing)
    assert_raises(Order::InvalidTransition) do
      @paid.transition_to!(:shipped)
    end
  end

  test "shipped transition succeeds with tracking number" do
    @paid.transition_to!(:processing)
    @paid.update!(tracking_number: "TRACK123")
    @paid.transition_to!(:shipped)
    assert_equal "shipped", @paid.status
    assert_not_nil @paid.shipped_at
  end

  test "paid_at is set on paid transition" do
    @pending.transition_to!(:payment_pending)
    @pending.transition_to!(:paid)
    assert_not_nil @pending.paid_at
  end

  test "next_valid_statuses returns allowed transitions" do
    assert_equal ["payment_pending"], @pending.next_valid_statuses
    assert_equal ["paid", "cancelled"], @pending.tap { |o| o.transition_to!(:payment_pending) }.next_valid_statuses
  end

  test "total_in_dollars formats correctly" do
    assert_equal "$49.99", @pending.total_in_dollars
  end
end
