# frozen_string_literal: true

require 'eac_ruby_utils/core_ext'
require 'faraday'
require 'faraday/follow_redirects'
require 'faraday/gzip'
require 'faraday/multipart'

module EacEnvs
  module Http
    class Request
      class FaradayConnection
        enable_method_class
        common_constructor :request

        SETUPS = %i[multipart authorization follow_redirect gzip].freeze

        # @return [Faraday::Connection]
        def result
          ::Faraday.default_connection_options[:headers] = {}
          ::Faraday::Connection.new(connection_options) do |conn|
            SETUPS.each { |setup| send("setup_#{setup}", conn) }
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

        # @param conn [Faraday::Connection]
        def setup_authorization(conn)
          request.auth.if_present do |v|
            conn.request :authorization, :basic, v.username, v.password
          end
        end

        # @param conn [Faraday::Connection]
        def setup_follow_redirect(conn)
          conn.response :follow_redirects if request.follow_redirect?
        end

        # @param conn [Faraday::Connection]
        def setup_gzip(conn)
          conn.request :gzip
        end

        # @param conn [Faraday::Connection]
        def setup_multipart(conn)
          if body_with_file?
            conn.request :multipart, flat_encode: true
          else
            conn.request :url_encoded
          end
        end
      end
    end
  end
end
