class CreateRejectedRentals < ActiveRecord::Migration[8.0]
  def change
    create_table :rejected_rentals do |t|
      t.references :rental_transaction, null: false, foreign_key: true
      t.datetime :rejected_at, null: false

      t.timestamps
    end
  end
end
