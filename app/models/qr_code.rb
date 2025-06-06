class QrCode < ApplicationRecord
  belongs_to :rental_transaction
  belongs_to :user

  before_validation :set_payload, on: :create

  private

    def set_payload
      self.payload = {
        user: {
          name: user.name,
          email: user.email,
          address: user.address,
          phone_number: user.phone_number,
        },
        item: {
          name: rental_transaction.item_version.name
        },
      }
    end
end
