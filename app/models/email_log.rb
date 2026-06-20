class EmailLog < ApplicationRecord
  belongs_to :user, optional: true

  validates :mailer_class, :mailer_action, :to_email, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
