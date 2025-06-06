class CreateItemTaggings < ActiveRecord::Migration[8.0]
  def change
    create_table :item_taggings do |t|
      t.references :item, null: false, foreign_key: true
      t.references :item_tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
