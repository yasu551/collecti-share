class User < ApplicationRecord
  has_one :user_profile, dependent: :restrict_with_exception
  has_many :user_profile_versions, through: :user_profile, class_name: "UserProfileVersion"
  has_many :items, dependent: :restrict_with_exception
  has_many :lender_rental_transactions, class_name: "RentalTransaction", foreign_key: "lender_id", dependent: :restrict_with_exception
  has_many :borrower_rental_transactions, class_name: "RentalTransaction", foreign_key: "borrower_id", dependent: :restrict_with_exception
  has_many :messages, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :google_uid, presence: true, uniqueness: true

  delegate :address, :phone_number, :bank_account_info, to: :user_profile, allow_nil: true

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
