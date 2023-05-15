# frozen_string_literal: true

require 'active_support/core_ext/hash/conversions'
require 'eac_envs/http/error'
require 'eac_ruby_utils/core_ext'
require 'faraday'
require 'json'

module EacEnvs
  module Http
    class Response < ::StandardError
      common_constructor :request

      def raise_unless_200
        return nil if status == 200

        raise self
      end

      def status
        performed.status.to_i
      end

      delegate :url, to: :request

      def to_s
        "URL: #{url}\nStatus: #{status}\nBody:\n\n#{body_str}"
      end

      private

      def performed
        @performed ||= request.faraday_response
      rescue ::Faraday::Error
        raise ::EacEnvs::Http::Error
      end

      require_sub __FILE__, include_modules: true
    end
  end
end
