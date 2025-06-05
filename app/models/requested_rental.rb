class RequestedRental < ApplicationRecord
  belongs_to :rental_transaction

  validates :requested_at, presence: true

  before_validation :set_requested_at, on: :create

  private

    def set_requested_at
      self.requested_at = Time.current
    end
end
