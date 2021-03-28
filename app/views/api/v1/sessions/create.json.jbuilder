# frozen_string_literal: true

json.user do
  json.email @session_dto.email
  json.nickname @session_dto.nickname
  json.username @session_dto.username
  json.access_token @session_dto.access_token
  json.refresh_token @session_dto.refresh_token
  json.admin @session_dto.admin
  json.avatar @session_dto.avatar
end
json.meta @meta