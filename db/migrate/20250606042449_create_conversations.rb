class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
