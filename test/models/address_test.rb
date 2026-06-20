require "test_helper"

class AddressTest < ActiveSupport::TestCase
  def setup
    @alice_home = addresses(:alice_home)
    @user = users(:regular_user)
  end

  test "full_address returns formatted string" do
    assert_includes @alice_home.full_address, "123 Main Street"
    assert_includes @alice_home.full_address, "Austin"
    assert_includes @alice_home.full_address, "TX"
    assert_includes @alice_home.full_address, "78701"
  end

  test "name is required" do
    addr = Address.new(user: @user, line1: "123 St", city: "Austin", state: "TX", zip: "78701")
    assert_not addr.valid?
    assert addr.errors[:name].present?
  end

  test "line1 is required" do
    addr = Address.new(user: @user, name: "Alice", city: "Austin", state: "TX", zip: "78701")
    assert_not addr.valid?
    assert addr.errors[:line1].present?
  end

  test "setting default clears other defaults" do
    second = Address.create!(
      user: @user, name: "Alice", line1: "456 Oak Ave",
      city: "Austin", state: "TX", zip: "78702", default: false
    )
    second.update!(default: true)
    @alice_home.reload
    assert second.default?
    assert_not @alice_home.default?
  end

  test "default_first scope puts default address first" do
    second = Address.create!(
      user: @user, name: "Alice", line1: "456 Oak Ave",
      city: "Austin", state: "TX", zip: "78702", default: false
    )
    ordered = Address.for_user(@user).default_first
    assert_equal @alice_home.id, ordered.first.id
  end
end
