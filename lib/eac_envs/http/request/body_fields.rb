# frozen_string_literal: true

require 'eac_ruby_utils/core_ext'
require 'eac_envs/http/request/body_field'

module EacEnvs
  module Http
    class Request
      class BodyFields
        common_constructor :source_body

        # @return [Hash, nil]
        def to_h
          fields.if_present do |v|
            v.each_with_object({}) { |e, a| a[e.hash_key] = e.hash_value }
          end
        end

        # @return [Array<EacEnvs::Http::Request::BodyField>, nil]
        def fields
          source_body.if_present do |v|
            next nil unless v.is_a?(::Enumerable)

            if v.is_a?(::Hash)
              ::EacEnvs::Http::Request::BodyField.list_from_hash(v)
            else
              ::EacEnvs::Http::Request::BodyField.list_from_enumerable(v)
            end
          end
        end

        # @return [Boolean]
        def with_file?
          fields.if_present(false) { |v| v.any?(&:with_file?) }
        end
      end
    end
  end
end
