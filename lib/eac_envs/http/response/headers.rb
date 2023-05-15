# frozen_string_literal: true

require 'eac_ruby_utils/core_ext'

module EacEnvs
  module Http
    class Response < ::StandardError
      module Headers
        COMMON_HEADERS = %w[Content-Type].freeze
        HEADER_LINE_PARSER = /\A([^:]+):(.*)\z/.to_parser do |m|
          [m[1].strip, m[2].strip]
        end

        def header(name)
          hash_search(headers, name)
        end

        # @return [Hash<String, String>]
        def headers
          performed.headers.to_hash
        end

        COMMON_HEADERS.each do |header_key|
          define_method header_key.underscore do
            header(header_key)
          end
        end

        private

        def hash_search(hash, key)
          key = key.to_s.downcase
          hash.each do |k, v|
            return v if k.to_s.downcase == key
          end
          nil
        end
      end
    end
  end
end
