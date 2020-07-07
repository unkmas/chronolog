# frozen_string_literal: true

module Chronolog
  module Model
    extend ActiveSupport::Concern

    def self.configure
      yield self
    end

    def self.actions
      @actions ||= %w[create update destroy]
    end

    def self.actions=(value)
      @actions = value
    end

    included do
      belongs_to :changeable, polymorphic: true
      belongs_to :admin_user

      validates :changeset, :identifier, presence: true

      validates :action, inclusion: { in: Chronolog::Model.actions }

      scope :recent, -> { order(created_at: :desc) }
      scope :reverse_chron, -> { order(created_at: :desc) }

      def self.table_name_prefix
        'chronolog_'
      end
    end
  end
end
