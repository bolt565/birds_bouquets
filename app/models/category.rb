class Category < ApplicationRecord
  include InputSanitizable

  has_many :products, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }

  before_validation :generate_slug, if: -> { slug.blank? }

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:position, :name) }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize
  end
end
