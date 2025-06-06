class ApprovedRental < ApplicationRecord
  belongs_to :rental_transaction

  validates :approved_at, presence: true

  before_validation :set_approved_at, on: :create

  private

    def set_approved_at
      self.approved_at = Time.current
    end
end
