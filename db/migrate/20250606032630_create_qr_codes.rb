class CreateQrCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :qr_codes do |t|
      t.references :rental_transaction, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.jsonb :payload, null: false, default: {}

      t.timestamps
    end
  end
end
