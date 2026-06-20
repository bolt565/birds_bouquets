require "test_helper"
require "ostruct"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:regular_user)
    @admin = users(:admin_user)
  end

  test "admin? returns false for regular user" do
    assert_not @user.admin?
  end

  test "admin? returns true for admin user" do
    assert @admin.admin?
  end

  test "email is required" do
    user = User.new(name: "Test", password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert user.errors[:email].present?
  end

  test "name is required" do
    user = User.new(email: "test@example.com", password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert user.errors[:name].present?
  end

  test "from_omniauth creates new user from Google auth" do
    auth = OpenStruct.new(
      provider: "google_oauth2",
      uid: "999999",
      info: OpenStruct.new(email: "newuser@google.com", name: "New User", image: "https://example.com/photo.jpg")
    )
    user = User.from_omniauth(auth)
    assert user.persisted?
    assert_equal "google_oauth2", user.provider
    assert_equal "999999", user.uid
    assert_equal "newuser@google.com", user.email
  end

  test "from_omniauth finds existing user by provider/uid" do
    @user.update!(provider: "google_oauth2", uid: "123456")
    auth = OpenStruct.new(
      provider: "google_oauth2",
      uid: "123456",
      info: OpenStruct.new(email: @user.email, name: @user.name, image: nil)
    )
    found = User.from_omniauth(auth)
    assert_equal @user.id, found.id
  end
end
