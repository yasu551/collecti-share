class Review < ApplicationRecord
  RATING_OPTIONS = (1..5).to_a.freeze

  belongs_to :rental_transaction
  belongs_to :user

  validates :rating, presence: true, inclusion: { in: RATING_OPTIONS }
end
