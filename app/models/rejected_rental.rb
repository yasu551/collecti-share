class RejectedRental < ApplicationRecord
  belongs_to :rental_transaction

  validates :rejected_at, presence: true

  before_validation :set_rejected_at, on: :create

  private

    def set_rejected_at
      self.rejected_at = Time.current
    end
end
