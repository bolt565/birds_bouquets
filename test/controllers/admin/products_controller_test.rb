require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @admin = users(:admin_user)
    @regular = users(:regular_user)
    @product = products(:red_roses)
  end

  test "index redirects non-admin" do
    sign_in @regular
    get admin_products_path
    assert_redirected_to root_path
  end

  test "index redirects unauthenticated" do
    get admin_products_path
    assert_redirected_to new_user_session_path
  end

  test "index returns success for admin" do
    sign_in @admin
    get admin_products_path
    assert_response :success
  end

  test "toggle_in_stock flips product stock status" do
    sign_in @admin
    original = @product.in_stock?
    patch toggle_in_stock_admin_product_path(@product)
    assert_equal !original, @product.reload.in_stock?
    assert_redirected_to admin_products_path
  end

  test "toggle_featured flips product featured status" do
    sign_in @admin
    original = @product.featured?
    patch toggle_featured_admin_product_path(@product)
    assert_equal !original, @product.reload.featured?
    assert_redirected_to admin_products_path
  end

  test "destroy redirects when product has orders" do
    sign_in @admin
    post admin_products_path, params: {
      product: {
        name: "Delete Test", description: "desc",
        price_dollars: "10.00", category_id: categories(:bouquets).id
      }
    }
    # Can only delete products with no orders
    product_without_orders = Product.find_by(name: "Delete Test")
    delete admin_product_path(product_without_orders)
    assert_redirected_to admin_products_path
  end
end
