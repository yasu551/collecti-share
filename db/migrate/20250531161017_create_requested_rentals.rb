class CreateRequestedRentals < ActiveRecord::Migration[8.0]
  def change
    create_table :requested_rentals do |t|
      t.references :rental_transaction, null: false, foreign_key: true, index: { unique: true }
      t.datetime :requested_at, null: false

      t.timestamps
    end
  end
end
