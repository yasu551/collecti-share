class CreateItemTags < ActiveRecord::Migration[8.0]
  def change
    create_table :item_tags do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
