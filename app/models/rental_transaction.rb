class RentalTransaction < ApplicationRecord
  belongs_to :lender, class_name: "User", foreign_key: "lender_id"
  belongs_to :borrower, class_name: "User", foreign_key: "borrower_id"
  belongs_to :item_version
  has_one :requested_rental, dependent: :restrict_with_exception

  validates :starts_on, presence: true
  validates :ends_on, presence: true
  validates :borrower_id, uniqueness: { scope: :item_version_id }
end
