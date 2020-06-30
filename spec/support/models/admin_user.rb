# frozen_string_literal: true

class AdminUser < ActiveRecord::Base
  devise :database_authenticatable, :validatable
end
