# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |i| "test#{i}@test.com" }
    password { 'password' }
  end
end
