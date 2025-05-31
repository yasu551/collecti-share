class CreateItemVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :item_versions do |t|
      t.references :item, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false, default: ""
      t.string :condition, null: false, default: "good"
      t.integer :daily_price, null: false, default: 1_000
      t.string :availability_status, null: false, default: "unavailable"

      t.timestamps
    end
  end
end
