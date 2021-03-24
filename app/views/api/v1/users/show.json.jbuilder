# frozen_string_literal: true

if @user.present?
  json.content @user, partial: 'user', as: :user
else
  json.content {}
end
json.meta @meta
