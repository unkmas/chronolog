# frozen_string_literal: true

FactoryBot.define do
  factory :changeset, class: Chronolog::Changeset do
    admin_user
    changeable { create :post }
    changeset  { { 'first_name' => %w[Fred Bo] } }
    action     { 'update' }
    identifier { 'Such Post (Post)' }

    trait :create do
      action { 'create' }
    end

    trait :update do
      action { 'update' }
    end

    trait :delete do
      action { 'delete' }
    end
  end
end
