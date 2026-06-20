require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @admin = users(:admin_user)
    @order = orders(:pending_order)
    @paid_order = orders(:paid_order)
  end

  test "index requires admin" do
    get admin_orders_path
    assert_redirected_to new_user_session_path
  end

  test "index returns success for admin" do
    sign_in @admin
    get admin_orders_path
    assert_response :success
  end

  test "index filters by status" do
    sign_in @admin
    get admin_orders_path(status: "pending")
    assert_response :success
  end

  test "show returns order details" do
    sign_in @admin
    get admin_order_path(@order)
    assert_response :success
  end

  test "update_status transitions order" do
    sign_in @admin
    patch update_status_admin_order_path(@order), params: { status: "payment_pending" }
    assert_equal "payment_pending", @order.reload.status
    assert_redirected_to admin_order_path(@order)
  end

  test "update_status with invalid transition shows error" do
    sign_in @admin
    patch update_status_admin_order_path(@order), params: { status: "delivered" }
    assert_equal "pending", @order.reload.status
    assert_redirected_to admin_order_path(@order)
    assert flash[:alert].present?
  end

  test "add_tracking updates order tracking number" do
    sign_in @admin
    patch add_tracking_admin_order_path(@paid_order), params: { tracking_number: "USPS1234567890" }
    assert_equal "USPS1234567890", @paid_order.reload.tracking_number
    assert_redirected_to admin_order_path(@paid_order)
  end
end
