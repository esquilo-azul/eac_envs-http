# frozen_string_literal: true

require 'active_support/core_ext/hash/conversions'
require 'eac_envs/http/error'
require 'eac_ruby_utils/core_ext'
require 'faraday'
require 'json'

module EacEnvs
  module Http
    class Response < ::StandardError
      # https://www.w3.org/wiki/LinkHeader
      LINKS_HEADER_NAME = 'Link'

      # https://www.w3.org/wiki/LinkHeader
      LINK_PARSER = /\A\<(.+)\>\s*;\s*rel\s*=\s*\"(.*)\"\z/.to_parser do |m|
        [m[2], m[1]]
      end

      common_constructor :request

      def link(rel)
        hash_search(links, rel)
      end

      def links
        header(LINKS_HEADER_NAME).if_present({}) do |v|
          v.split(',').map { |w| LINK_PARSER.parse!(w.strip) }.to_h
        end
      end

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
