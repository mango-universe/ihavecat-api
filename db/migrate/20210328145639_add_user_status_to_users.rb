class AddUserStatusToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :user_status, :string, after: :birth
  end
end
