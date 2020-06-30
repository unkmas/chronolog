# frozen_string_literal: true

module Chronolog
  module ActiveAdmin
    module TrackChanges
      private

      def track_changes
        controller do
          before_action :store_old_state,  only: %i[update destroy]
          before_action :store_identifier, only: [:destroy]
          after_action  :create_changeset, only: %i[create update destroy]

          private

          def resource_attributes
            clone = resource_class.find(resource.id)

            if clone.respond_to?(:diff_attributes)
              clone.diff_attributes
            else
              Chronolog::DiffRepresentation.new(clone).attributes
            end
          end

          def store_old_state
            @old_state = resource_attributes
          end

          def store_identifier
            @identifier = "#{resource.id} (#{resource.class.to_s.titleize})"
          end

          def create_changeset
            if resource.errors.none?
              changeset_attrs = {
                admin_user: current_admin_user,
                action: params[:action],
                identifier: @identifier,
                old_state: @old_state
              }

              unless params[:action] == 'destroy'
                changeset_attrs.merge!(
                  target: resource,
                  new_state: resource_attributes
                )
              end

              Chronolog::ChangeTracker.new(changeset_attrs).changeset
            end
          end
        end
      end

      def track_batch_changes
        controller do
          before_action :store_old_states,  only: [:batch_action]
          before_action :store_identifiers, only: [:batch_action]
          after_action  :create_changesets, only: [:batch_action]

          private

          def store_old_states
            @old_states = params[:collection_selection].map { |id| resource_attributes_by_id(id) }
          end

          def store_identifiers
            @identifiers = params[:collection_selection].map { |id| "#{id} (#{resource_class.to_s.titleize})" }
          end

          def resource_attributes_by_id(id)
            clone = resource_class.find(id)

            if clone.respond_to?(:diff_attributes)
              clone.diff_attributes
            else
              Chronolog::DiffRepresentation.new(clone).attributes
            end
          end

          def create_changesets
            params[:collection_selection].each do
              changeset_attrs = {
                admin_user: current_admin_user,
                action: params[:batch_action],
                identifier: @identifiers.pop,
                old_state: @old_states.pop
              }

              Chronolog::ChangeTracker.new(changeset_attrs).changeset
            end
          end
        end
      end
    end
  end
end
