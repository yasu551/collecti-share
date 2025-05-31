class User < ApplicationRecord
  has_one :user_profile, dependent: :destroy
  has_many :user_profile_versions, through: :user_profile, class_name: "UserProfileVersion"

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :google_uid, presence: true, uniqueness: true

  delegate :address, :phone_number, to: :user_profile, allow_nil: true

  class << self
    def find_or_create_from_auth_hash(auth_hash)
      transaction do
        user =
          where(email: auth_hash[:info][:email], google_uid: auth_hash[:uid]).first_or_create! do |u|
            u.name = auth_hash[:info][:name]
          end
        user.create_user_profile!
      end
    end
  end
end
