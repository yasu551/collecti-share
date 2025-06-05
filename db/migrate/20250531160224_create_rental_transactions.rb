class CreateRentalTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :rental_transactions do |t|
      t.references :lender, null: false, foreign_key: { to_table: :users }
      t.references :borrower, null: false, index: false, foreign_key: { to_table: :users }
      t.references :item_version, null: false, foreign_key: true
      t.date :starts_on, null: false
      t.date :ends_on, null: false

      t.timestamps
    end

    add_index :rental_transactions, %i[borrower_id item_version_id], unique: true
  end
end
