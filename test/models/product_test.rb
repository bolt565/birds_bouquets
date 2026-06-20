require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @product = products(:red_roses)
    @sunflowers = products(:sunflowers)
    @out_of_stock = products(:out_of_stock_product)
  end

  test "price_in_dollars formats correctly" do
    assert_equal "$49.99", @product.price_in_dollars
    assert_equal "$29.99", @sunflowers.price_in_dollars
  end

  test "on_sale? returns true when compare price is higher" do
    assert @product.on_sale?
  end

  test "on_sale? returns false when no compare price" do
    assert_not @sunflowers.on_sale?
  end

  test "sold_out? reflects in_stock status" do
    assert_not @product.sold_out?
    assert @out_of_stock.sold_out?
  end

  test "slug is generated from name" do
    product = Product.new(name: "Spring Garden Bouquet", description: "Fresh", price_cents: 2999)
    product.valid?
    assert_equal "spring-garden-bouquet", product.slug
  end

  test "in_stock scope excludes out-of-stock products" do
    in_stock = Product.in_stock
    assert in_stock.include?(@product)
    assert_not in_stock.include?(@out_of_stock)
  end

  test "featured scope returns only featured products" do
    assert Product.featured.include?(@product)
    assert_not Product.featured.include?(@sunflowers)
  end

  test "price_cents must be positive" do
    product = Product.new(name: "Test", slug: "test-slug", description: "test", price_cents: 0)
    assert_not product.valid?
    assert product.errors[:price_cents].present?
  end

  test "description is required" do
    product = Product.new(name: "Test", slug: "test-slug", price_cents: 1000)
    assert_not product.valid?
    assert product.errors[:description].present?
  end
end
