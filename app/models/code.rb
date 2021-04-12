# == Schema Information
#
# Table name: codes
#
#  id         :bigint           not null, primary key
#  parent_id  :integer
#  uuid       :integer          default(0), not null
#  name       :string(255)      default(""), not null
#  eng_name   :string(255)      default("")
#  value      :string(255)      default("")
#  icon_url   :string(255)
#  position   :integer          default(0), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Code < ApplicationRecord
  acts_as_paranoid

  belongs_to :parent, :class_name => 'Code', :foreign_key => 'parent_id', optional: true
  has_many :items, :class_name => 'Code', :foreign_key => 'parent_id', dependent: :destroy

  validates :name, presence: true
  # 상위 코드일 경우에만 uniquencess 를 검사한다.
  # 다른 코드베이스 내에 같은 이름의 값이 존재할 수 있기 때문
  validates :name, uniqueness: true, if: -> { parent.nil? }

  enum code: { notification: 11 }

  scope :parent_codes, -> { where(parent_id: nil) }
  scope :abstract_codes, -> { where(parent_id: nil).where.not(id: Code.where(name: Code.codes.keys)) }

end
