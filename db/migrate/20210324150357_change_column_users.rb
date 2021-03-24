class ChangeColumnUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :username, :string, unique: false
    change_column :users, :nickname, :string, unique: true
  end
end
