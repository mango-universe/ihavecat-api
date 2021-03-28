class ChangeTokenLengthToUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :refresh_token, :string, null: false, default: '', length: 1024
    change_column :users, :access_token, :string, null: false, default: '', length: 1024
  end
end
