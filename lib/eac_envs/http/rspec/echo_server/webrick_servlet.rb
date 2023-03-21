# frozen_string_literal: true

require 'eac_envs/http/request'
require 'eac_envs/http/rspec/echo_server/request_processor'
require 'eac_ruby_utils/core_ext'
require 'webrick'

module EacEnvs
  module Http
    module Rspec
      class EchoServer
        class WebrickServlet < WEBrick::HTTPServlet::AbstractServlet
          ::EacEnvs::Http::Request.lists.verb.each_value do |verb|
            define_method "do_#{verb.to_s.upcase}" do |request, response|
              ::EacEnvs::Http::Rspec::EchoServer::RequestProcessor.new(request, response).perform
            end
          end
        end
      end
    end
  end
end
