class ChangeIndexUsers < ActiveRecord::Migration[6.1]
  def change
    remove_index :users, :username
    add_index :users, :nickname, unique: true
    add_index :users, :username
  end
end
