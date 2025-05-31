class User < ApplicationRecord
  has_one :user_profile, dependent: :destroy
  has_many :user_profile_versions, through: :user_profile, class_name: "UserProfileVersion"

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :google_uid, presence: true, uniqueness: true

  class << self
    def find_or_create_from_auth_hash(auth_hash)
      where(email: auth_hash[:info][:email], google_uid: auth_hash[:uid]).first_or_create do |user|
        user.name = auth_hash[:info][:name]
      end
    end
  end
end
