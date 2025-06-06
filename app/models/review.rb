class Review < ApplicationRecord
  belongs_to :rental_transaction
  belongs_to :user
end
