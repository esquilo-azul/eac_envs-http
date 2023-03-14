# frozen_string_literal: true

require 'eac_envs/http/request/body_field_value'
require 'eac_ruby_utils/core_ext'
require 'faraday/multipart/file_part'

module EacEnvs
  module Http
    class Request
      class BodyField
        class << self
          # @return [Array<EacEnvs::Http::Request::BodyField>]
          def list_from_enumerable(enum)
            hash = {}
            enum.each do |v|
              hash[v[0]] ||= []
              hash[v[0]] << v[1]
            end
            list_from_hash(hash)
          end

          # @return [Array<EacEnvs::Http::Request::BodyField>]
          def list_from_hash(hash)
            hash.map { |k, v| new(k, v) }
          end
        end

        common_constructor :key, :values do
          self.key = key.to_s
          self.values = (values.is_a?(::Array) ? values.to_a : [values])
                        .map { |v| ::EacEnvs::Http::Request::BodyFieldValue.new(v) }
        end

        # @return [String]
        def hash_key
          key
        end

        # @return [Array]
        def hash_value
          values.map(&:to_faraday)
        end

        # @return [Boolean]
        def with_file?
          values.any?(&:file?)
        end
      end
    end
  end
end
