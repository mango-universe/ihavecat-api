class ChangeTokenLengthToUsers2 < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :refresh_token, :string, null: false, default: '', limit: 1024
    change_column :users, :access_token, :string, null: false, default: '', limit: 1024
  end
end
