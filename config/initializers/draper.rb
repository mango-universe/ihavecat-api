# frozen_string_literal: true

# draper 와 kaminary gem 을 함께 사용할 경우
# kaminary 내의 일부 함수를 사용하지 못하는 문제가 발생함
# 해당 문제를 fix하기 위해 아래의 구문을 사용함
Draper::CollectionDecorator.delegate :currentPage, :totalPages, :limit_value, :totalCount
