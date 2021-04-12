# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  username               :string(255)      default(""), not null
#  nickname               :string(255)      default("unknown"), not null
#  admin                  :boolean          default(FALSE), not null
#  avatar                 :string(255)
#  description            :string(255)      default(""), not null
#  online                 :boolean          default(FALSE), not null
#  birth                  :datetime
#  user_status            :string(255)
#  access_token           :string(1024)     default(""), not null
#  refresh_token          :string(1024)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ApplicationRecord
  include AASM

  acts_as_paranoid
  acts_as_taggable
  acts_as_reader
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :async, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessor :request_ip, :user_agent

  ACCESS_TOKEN_DURATION = 24 * 60 * 60
  REFRESH_TOKEN_DURATION = 15 * 24 * 60 * 60

  validates :nickname, uniqueness: true

  aasm column: 'user_status' do
    state :waiting, init: true # 가입 확인
    state :actived             # 가입 승인
    state :rejected            # 가입 승인 거절
    state :banned              # 차단
    state :leaved              # 탈퇴
    state :dormanted           # 휴면

    event :activate do
      transitions from: [:waiting, :rejected], to: :actived # 차단/휴면 상태에서는 승인 불가
    end

    event :leave, before: [:invalidate_password] do
      transitions from: [:waiting, :active, :rejected], to: :leaved # 차단/휴면 상태에서는 탈퇴 불가
    end
  end

  before_update :activate, if: Proc.new { |t| t.confirmed_at_changed? and !t.confirmed_at_change[1].nil? }

  has_many :boards, dependent: :destroy


  def generate_tokens
    self.access_token = generate_jwt_token(ACCESS_TOKEN_DURATION)
    self.refresh_token = generate_jwt_token(REFRESH_TOKEN_DURATION, SecureRandom.hex(16))
    raise ApiExceptions::CustomException.new(:service_unavailable, 'token create error.') unless self.access_token and self.refresh_token
  end

  private

  def generate_jwt_token(duration, key='')
    issued_at = not_before = Time.current.to_i
    expire = not_before + duration
    jwt = {
      iss: 'ihavecat.net',
      jti: email,
      iat: issued_at,
      nbf: not_before,
      exp: expire,
      data: {
        ip: request_ip,
        user_agent: user_agent,
        key: key,
      }
    }

    JsonWebToken.encode(jwt)
  end

  # 유저 탈퇴시 처리 : invalidate_password, deny_permission
  def invalidate_password
    self.encrypted_password = 'abc' + self.encrypted_password
  end

end
