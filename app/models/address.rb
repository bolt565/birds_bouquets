class Address < ApplicationRecord
  include InputSanitizable

  belongs_to :user
  has_many :orders, foreign_key: :user_id, primary_key: :user_id

  validates :name, :line1, :city, :state, :zip, :country, presence: true

  before_save :clear_other_defaults, if: -> { default_changed? && self.default? }

  scope :default_first, -> { order(default: :desc, created_at: :asc) }
  scope :for_user, ->(user) { where(user: user) }

  def full_address
    parts = [line1, line2, "#{city}, #{state} #{zip}", country]
    parts.compact_blank.join(", ")
  end

  private

  def clear_other_defaults
    user.addresses.where.not(id: id).update_all(default: false)
  end
end
