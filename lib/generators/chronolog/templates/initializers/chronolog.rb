# frozen_string_literal: true

# Adds `track_changes` to ActiveAdmin DSL
ActiveAdmin::ResourceDSL.include Chronolog::ActiveAdmin::TrackChanges
