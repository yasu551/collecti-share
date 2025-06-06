class UserProfile < ApplicationRecord
  belongs_to :user
  has_one :current_user_profile_version, -> { latest }, class_name:  "UserProfileVersion"
  has_many :user_profile_versions, dependent: :restrict_with_exception

  delegate :address, :phone_number, :bank_account_info, to: :current_user_profile_version, allow_nil: true

  def build_user_profile_version_from_current_version
    user_profile_versions.build(address:, phone_number:, bank_account_info:)
  end
end
