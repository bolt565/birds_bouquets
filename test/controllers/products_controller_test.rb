require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index returns success" do
    get products_path
    assert_response :success
  end

  test "index filters by category slug" do
    get products_path(category: "bouquets")
    assert_response :success
  end

  test "index with unknown category still succeeds" do
    get products_path(category: "nonexistent")
    assert_response :success
  end

  test "show returns success for valid slug" do
    get product_path(products(:red_roses))
    assert_response :success
  end

  test "show returns 404 for unknown slug" do
    get product_path("nonexistent-slug")
    assert_response :not_found
  end
end
