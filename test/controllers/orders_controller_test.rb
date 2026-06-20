require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:regular_user)
    @order = orders(:pending_order)
  end

  test "index redirects to sign in when not logged in" do
    get orders_path
    assert_redirected_to new_user_session_path
  end

  test "index returns success when logged in" do
    sign_in @user
    get orders_path
    assert_response :success
  end

  test "show returns success for own order" do
    sign_in @user
    get order_path(@order)
    assert_response :success
  end

  test "show redirects for another user's order" do
    other = users(:admin_user)
    sign_in other
    get order_path(@order)
    assert_redirected_to orders_path
  end

  test "lookup renders form" do
    get orders_lookup_path
    assert_response :success
  end

  test "find with valid email and order number renders order" do
    post orders_find_path, params: {
      email: @order.email,
      order_number: @order.order_number
    }
    assert_response :success
  end

  test "find with invalid data rerenders lookup form" do
    post orders_find_path, params: {
      email: "wrong@example.com",
      order_number: "BB-0000-00000"
    }
    assert_response :success
  end
end
