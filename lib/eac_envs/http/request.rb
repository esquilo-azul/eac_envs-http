# frozen_string_literal: true

require 'eac_envs/http/response'
require 'eac_ruby_utils/core_ext'
require 'faraday'
require 'faraday/multipart'

module EacEnvs
  module Http
    class Request
      BOOLEAN_MODIFIERS = %w[ssl_verify].freeze
      COMMON_MODIFIERS = %w[auth body_data response_body_data_proc url verb].freeze
      HASH_MODIFIERS = %w[header].freeze
      MODIFIERS = COMMON_MODIFIERS + BOOLEAN_MODIFIERS + HASH_MODIFIERS.map(&:pluralize)

      enable_immutable
      immutable_accessor(*BOOLEAN_MODIFIERS, type: :boolean)
      immutable_accessor(*COMMON_MODIFIERS, type: :common)
      immutable_accessor(*HASH_MODIFIERS, type: :hash)

      enable_listable
      lists.add_symbol :verb, :get, :delete, :options, :post, :put

      def basic_auth(username, password)
        auth(::Struct.new(:username, :password).new(username, password))
      end

      # @return [Faraday::Connection]
      def faraday_connection
        ::Faraday.default_connection_options[:headers] = {}
        ::Faraday::Connection.new(faraday_connection_options) do |conn|
          if body_with_file?
            conn.request :multipart, flat_encode: true
          else
            conn.request :url_encoded
          end
          auth.if_present { |v| conn.request :authorization, :basic, v.username, v.password }
        end
      end

      # @return [Hash]
      def faraday_connection_options
        {
          request: { params_encoder: Faraday::FlatParamsEncoder }, ssl: { verify: ssl_verify? }
        }
      end

      # @return [Faraday::Response]
      def faraday_response
        conn = faraday_connection
        conn.send(sanitized_verb, url) do |req|
          req.headers = conn.headers.merge(headers)
          sanitized_body_data.if_present { |v| req.body = v }
        end
      end

      def response
        ::EacEnvs::Http::Response.new(self)
      end

      # @return [Symbol]
      def sanitized_verb
        verb.if_present(VERB_GET) { |v| self.class.lists.verb.value_validate!(v) }
      end

      private

      def body_fields
        @body_fields ||= ::EacEnvs::Http::Request::BodyFields.new(body_data)
      end

      # @return [Boolean]
      def body_with_file?
        body_fields.with_file?
      end

      def sanitized_body_data
        body_fields.to_h || body_data
      end

      require_sub __FILE__
    end
  end
end