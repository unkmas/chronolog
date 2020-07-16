# frozen_string_literal: true

module Chronolog
  class DiffRepresentation
    DEFAULT_IGNORED = %w[
      id
      created_at
      updated_at
    ].freeze

    attr_reader :record,
                :associations,
                :methods,
                :ignored_attrs

    def initialize(record, options = {})
      @record        = record
      @associations  = find_associations_for Array(options[:include])
      @methods       = Array(options[:methods])
      @ignored_attrs = DEFAULT_IGNORED + Array(options[:ignore]).map(&:to_s)
    end

    def attributes
      @attributes ||= record_attributes
                      .merge(attributes_for_associations)
                      .merge(attributes_for_methods)
                      .delete_if { |_, value| value.blank? || value == '[]' }
    end

    private

    def find_associations_for(names)
      record.class.reflect_on_all_associations.select do |association|
        names.map(&:to_s).include? association.name.to_s
      end
    end

    def dependencies
      @dependencies ||= record.class.reflect_on_all_associations(:belongs_to)
    end

    def base_attributes
      @base_attributes ||= record.as_json.delete_if do |attr, _value|
        ignored_attrs.include?(attr)
      end
    end

    def record_attributes
      base_attributes.reduce({}) do |output, (attr, value)|
        output.merge normalize_attribute(attr, value)
      end
    end

    def attributes_for_associations
      associations.reduce({}) do |output, association|
        associated = record.send(association.name).order(:id)

        if associated.any?
          output.merge(association.name.to_s => associated.map do |item|
            if item.respond_to?(:diff_attributes)
              item.diff_attributes
            else
              self.class.new(item).attributes
            end
          end)
        else
          output
        end
      end
    end

    def attributes_for_methods
      methods.reduce({}) do |output, method|
        output.merge normalize_attribute(method.to_s, @record.send(method))
      end
    end

    def normalize_attribute(attr, value)
      dependency = dependencies.find { |association| association.foreign_key.to_s == attr.to_s }

      if dependency.present?
        { dependency.name.to_s => record.send(dependency.name).try(:id) }
      elsif attr =~ /(.*)_ids$/ && record.respond_to?(Regexp.last_match(1).pluralize)
        { Regexp.last_match(1).pluralize => record.send(Regexp.last_match(1).pluralize).map(&:to_s) }
      elsif attr =~ /(.*)_date$/ && value.present? && DateTime.parse(value)
        { attr => DateTime.parse(value).strftime('%A %B %e, %Y') }
      else
        { attr => value }
      end
    end
  end
end
