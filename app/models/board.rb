# == Schema Information
#
# Table name: boards
#
#  id              :bigint           not null, primary key
#  user_id         :bigint
#  group_id        :integer
#  depth           :integer          default(1), not null
#  seq             :integer          default(1), not null
#  board_type      :integer          default(0), not null
#  category_id     :integer
#  title           :string(255)      default(""), not null
#  body            :text(65535)      not null
#  likes_count     :bigint           default(0), not null
#  bookmarks_count :bigint           default(0), not null
#  comments_count  :bigint           default(0), not null
#  answer_count    :bigint           default(0), not null
#  cached_tag_list :string(255)
#  publish         :boolean          default(TRUE)
#  attachments     :text(65535)
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Board < ApplicationRecord
  acts_as_paranoid
  acts_as_taggable
  acts_as_readable on: :created_at

  enum board_type: [:normal, :qna, :my_note]

  after_create :update_group

  belongs_to :user
  belongs_to :category, class_name: 'Code', foreign_key: :category_id, optional: true


  private

  # 계층형 게시판을 위해서 create이후 group_id, seq, depth등을 업데이트 한다.
  def update_group
    if self.group_id.blank?
      self.update_columns(group_id: self.id)
    else
      board = Board.find(self.group_id)
      board.touch # 답변 달린 시간으로 질문글의 updated_at을 설정
      self.update_columns(depth: (board.depth+1), category_id: board.category_id)
    end
  end
end
