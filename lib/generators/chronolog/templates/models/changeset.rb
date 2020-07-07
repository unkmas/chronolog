# frozen_string_literal: true

module Chronolog
  class Changeset < ActiveRecord::Base
    include Chronolog::Model
  end
end
