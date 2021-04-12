class CreateBoards < ActiveRecord::Migration[6.1]
  def change
    create_table :boards do |t|
      t.references :user, foreign_key: true
      # 답변 기능 칼럼
      t.integer :group_id
      t.integer :depth, null: false, default: 1
      t.integer :seq, null: false, default: 1

      t.integer :board_type, null: false, default: 0
      t.integer :category_id

      t.string :title, null: false, default: ""
      t.text :body, null: false

      t.integer :likes_count, null: false, default: 0, limit: 8
      t.integer :bookmarks_count, null: false, default: 0, limit: 8
      t.integer :comments_count, null: false, default: 0, limit: 8
      t.integer :answer_count, null: false, default: 0, limit: 8

      # 태그 캐싱
      t.string :cached_tag_list
      # 공개 여부
      t.boolean :publish, default: true
      # 첨부 파일
      t.text :attachments

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
