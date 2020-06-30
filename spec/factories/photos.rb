# frozen_string_literal: true

FactoryBot.define do
  factory :photo do
    sequence(:url) { |i| "https://www.test-#{i}.com" }
  end
end
