# frozen_string_literal: true

require 'eac_envs/http/rspec/echo_server/webrick_servlet'
require 'eac_ruby_utils/core_ext'
require 'webrick'
# require 'webrick/https'

module EacEnvs
  module Http
    module Rspec
      class EchoServer
        class HttpServer < ::WEBrick::HTTPServer
          def initialize(options)
            super
            mount '/', ::EacEnvs::Http::Rspec::EchoServer::WebrickServlet
          end
        end
      end
    end
  end
end
