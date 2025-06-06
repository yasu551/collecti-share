class AddBankAccountInfoToUserProfileVersions < ActiveRecord::Migration[8.0]
  def change
    add_column :user_profile_versions, :bank_account_info, :text, null: false, default: ""
  end
end
