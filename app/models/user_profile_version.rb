class UserProfileVersion < ApplicationRecord
  belongs_to :user_profile

  validates :address, presence: true
  validates :phone_number, presence: true
  validates :bank_account_info, presence: true

  scope :latest, -> { order(created_at: :desc) }
end
