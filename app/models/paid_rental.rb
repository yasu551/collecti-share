class PaidRental < ApplicationRecord
  belongs_to :rental_transaction

  validates :paid_at, presence: true

  before_validation :set_paid_at, on: :create

  private

    def set_paid_at
      self.paid_at = Time.current
    end
end
