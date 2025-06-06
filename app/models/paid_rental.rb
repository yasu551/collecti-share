class PaidRental < ApplicationRecord
  belongs_to :rental_transaction

  validates :paid_at, presence: true

  before_validation :set_paid_at, on: :create
  after_create :create_rental_transaction_qr_codes!

  private

    def set_paid_at
      self.paid_at = Time.current
    end

    def create_rental_transaction_qr_codes!
      rental_transaction.create_qr_codes!
    end
end
