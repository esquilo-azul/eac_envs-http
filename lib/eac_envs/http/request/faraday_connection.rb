# frozen_string_literal: true

require 'eac_ruby_utils/core_ext'
require 'faraday'
require 'faraday/multipart'

module EacEnvs
  module Http
    class Request
      class FaradayConnection
        enable_method_class
        common_constructor :request

        # @return [Faraday::Connection]
        def result
          ::Faraday.default_connection_options[:headers] = {}
          ::Faraday::Connection.new(connection_options) do |conn|
            if body_with_file?
              conn.request :multipart, flat_encode: true
            else
              conn.request :url_encoded
            end
            request.auth
                   .if_present { |v| conn.request :authorization, :basic, v.username, v.password }
          end
        end

        private

        # @return [Boolean]
        def body_with_file?
          request.body_fields.with_file?
        end

        # @return [Hash]
        def connection_options
          {
            request: { params_encoder: Faraday::FlatParamsEncoder },
            ssl: { verify: request.ssl_verify? }
          }
        end
      end
    end
  end
end
