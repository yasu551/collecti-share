class ReturnedRental < ApplicationRecord
  belongs_to :rental_transaction

  validates :returned_at, presence: true

  before_validation :set_returned_at, on: :create

  private

    def set_returned_at
      self.returned_at = Time.current
    end
end
