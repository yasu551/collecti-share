class ShippedRental < ApplicationRecord
  belongs_to :rental_transaction

  validates :shipped_at, presence: true

  before_validation :set_shipped_at, on: :create

  private

  def set_shipped_at
    self.shipped_at = Time.current
  end
end
