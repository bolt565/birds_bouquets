class User < ApplicationRecord
  include InputSanitizable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :addresses, dependent: :destroy
  has_many :orders

  validates :name, presence: true
  validates :email, presence: true

  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    user ||= find_by(email: auth.info.email)

    user ||= new(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      name: auth.info.name,
      avatar_url: auth.info.image,
      password: Devise.friendly_token[0, 20]
    )

    user.provider = auth.provider
    user.uid = auth.uid
    user.avatar_url = auth.info.image if auth.info.image.present?
    user.save!
    user
  end

  def admin?
    admin == true
  end

  def default_address
    addresses.find_by(default: true) || addresses.first
  end
end
