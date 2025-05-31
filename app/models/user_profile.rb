class UserProfile < ApplicationRecord
  belongs_to :user
  has_many :user_profile_versions, dependent: :restrict_with_exception
  has_one :current_user_profile_version, -> { latest }, class_name:  "UserProfileVersion"

  delegate :address, :phone_number, to: :current_user_profile_version, allow_nil: true
end
