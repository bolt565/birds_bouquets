class BlogPost < ApplicationRecord
  include InputSanitizable

  STATUSES = %w[draft published].freeze

  validates :title, :body, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  before_validation :generate_slug, if: -> { slug.blank? }

  scope :published, -> { where(status: "published").order(published_at: :desc) }
  scope :drafts, -> { where(status: "draft") }

  def to_param
    slug
  end

  def publish!
    update!(status: "published", published_at: Time.current)
  end

  def unpublish!
    update!(status: "draft", published_at: nil)
  end

  def published?
    status == "published"
  end

  private

  def generate_slug
    self.slug = title.to_s.parameterize
  end
end
