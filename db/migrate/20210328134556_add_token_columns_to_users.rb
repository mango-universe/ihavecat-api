class AddTokenColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :refresh_token, :string, null: false, default: '', after: :birth
    add_column :users, :access_token, :string, null: false, default: '', after: :birth
  end
end
