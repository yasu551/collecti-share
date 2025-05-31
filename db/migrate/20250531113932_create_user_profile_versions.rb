class CreateUserProfileVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :user_profile_versions do |t|
      t.references :user_profile, null: false, foreign_key: true
      t.string :address, null: false
      t.string :phone_number, null: false

      t.timestamps
    end
  end
end
