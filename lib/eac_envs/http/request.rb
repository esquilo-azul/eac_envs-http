# frozen_string_literal: true

require 'eac_envs/http/response'
require 'eac_ruby_utils/core_ext'

module EacEnvs
  module Http
    class Request
      BOOLEAN_MODIFIERS = %w[follow_redirect retry ssl_verify].freeze
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

      # @return [EacEnvs::Http::Request::BodyFields]
      def body_fields
        @body_fields ||= ::EacEnvs::Http::Request::BodyFields.new(body_data)
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

      def sanitized_body_data
        body_fields.to_h || body_data
      end

      require_sub __FILE__, require_dependency: true
    end
  end
end
