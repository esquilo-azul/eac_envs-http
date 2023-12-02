# frozen_string_literal: true

require 'eac_envs/http/request'
require 'eac_ruby_utils/core_ext'
require 'webrick'

module EacEnvs
  module Http
    module Rspec
      class EchoServer
        class RequestProcessor
          REQUEST_TO_DATA = {
            ssl: :ssl?,
            method: :request_method,
            uri: :unparsed_uri,
            body: :body
          }.freeze

          common_constructor :request, :response

          def perform
            response.body = response_body
            response.header['Content-type'] = 'application/json'
            response.status = 200
          end

          def request_data
            REQUEST_TO_DATA.transform_values { |v| request.send(v) }.merge(headers: request_headers)
          end

          def request_headers
            request.header.transform_values(&:first)
          end

          def response_body
            ::JSON.generate(request_data)
          end
        end
      end
    end
  end
end
