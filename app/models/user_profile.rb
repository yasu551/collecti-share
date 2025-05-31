class UserProfile < ApplicationRecord
  belongs_to :user
  has_many :user_profile_versions, dependent: :destroy
end
