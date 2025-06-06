class CompletedRental < ApplicationRecord
  belongs_to :rental_transaction

  validates :completed_at, presence: true

  before_validation :set_completed_at, on: :create

  private

    def set_completed_at
      self.completed_at = Time.current
    end
end
