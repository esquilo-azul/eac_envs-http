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

          def on_running(&block)
            ::Thread.abort_on_exception = true
            servlet_thread = ::Thread.new { start }
            begin
              sleep 0.001 while status != :Running
              block.call
            ensure
              shutdown
              servlet_thread.join
            end
          end
        end
      end
    end
  end
end
