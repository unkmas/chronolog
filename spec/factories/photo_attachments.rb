# frozen_string_literal: true

FactoryBot.define do
  factory :photo_attachment do
    record { create :user }
    photo
  end
end
