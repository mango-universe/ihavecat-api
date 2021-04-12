class CreateCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :codes do |t|
      t.integer :parent_id
      # 고유 번호
      t.integer :uuid, null: false, default: 0
      t.string :name, null: false, default: ""
      t.string :eng_name, default: ""
      t.string :value, default: ""
      t.string :icon_url
      t.integer :position, null: false, default: 0

      t.datetime :deleted_at
      t.timestamps
    end

    add_index "codes", ["parent_id"], name: "index_codes_on_parent_id", using: :btree
    add_index "codes", ["uuid"], name: "index_codes_on_uuid", using: :btree
    add_index "codes", ["name"], name: "index_codes_on_name", using: :btree
  end
end
