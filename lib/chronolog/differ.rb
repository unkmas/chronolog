# frozen_string_literal: true

module Chronolog
  module Differ
    class << self
      def diff(original, current)
        (original.keys | current.keys).sort.each_with_object({}) do |key, diff|
          next unless original[key] != current[key]

          diff[key] = if original[key].is_a?(Array) && current[key].is_a?(Array)
                        [original[key] - current[key], current[key] - original[key]]
                      else
                        [original[key], current[key]]
                      end
        end
      end
    end
  end
end
