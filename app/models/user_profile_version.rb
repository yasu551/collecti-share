class UserProfileVersion < ApplicationRecord
  belongs_to :user_profile

  validates :address, presence: true
  validates :phone_number, presence: true
end
