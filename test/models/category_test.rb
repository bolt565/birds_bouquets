require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  def setup
    @bouquets = categories(:bouquets)
  end

  test "slug is generated from name" do
    cat = Category.new(name: "Holiday Arrangements", description: "Seasonal picks")
    cat.valid?
    assert_equal "holiday-arrangements", cat.slug
  end

  test "existing slug is not overwritten" do
    @bouquets.name = "New Name"
    @bouquets.valid?
    assert_equal "bouquets", @bouquets.slug
  end

  test "name is required" do
    cat = Category.new(description: "desc")
    assert_not cat.valid?
    assert cat.errors[:name].present?
  end

  test "active scope returns only active categories" do
    @bouquets.update!(active: false)
    assert_not Category.active.include?(@bouquets)
  end

  test "to_param returns slug" do
    assert_equal "bouquets", @bouquets.to_param
  end
end
