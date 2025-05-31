class RequestedRental < ApplicationRecord
  belongs_to :rental_transaction

  validates :requested_at, presence: true
end
