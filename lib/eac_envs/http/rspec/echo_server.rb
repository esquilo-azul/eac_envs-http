# frozen_string_literal: true

require 'addressable'
require 'eac_ruby_utils/core_ext'
require 'webrick'
require 'webrick/https'

module EacEnvs
  module Http
    module Rspec
      class EchoServer
        HOSTNAME = 'localhost'
        SCHEMES = {
          http: { Port: 8080 },
          https: { Port: 8443, SSLEnable: true, SSLCertName: [['CN', HOSTNAME]] }
        }.freeze

        class << self
          SCHEMES.each do |scheme, webrick_options|
            # @return [::EacEnvs::Http::Rspec::EchoServer]
            define_method scheme do
              new(scheme, webrick_options)
            end
          end
        end

        common_constructor :scheme, :webrick_options

        def on_active(&block)
          servlet = http_server
          ::Thread.abort_on_exception = true
          servlet_thread = ::Thread.new { servlet.start }
          begin
            sleep 0.001 while servlet.status != :Running
            block.call
          ensure
            servlet.shutdown
            servlet_thread.join
          end
        end

        def root_url
          ::Addressable::URI.new(
            scheme: scheme.to_s,
            host: ::EacEnvs::Http::Rspec::EchoServer::HOSTNAME,
            port: webrick_options.fetch(:Port)
          )
        end

        protected

        # @return [EacEnvs::Http::Rspec::EchoServer::HttpServer]
        def http_server
          ::EacEnvs::Http::Rspec::EchoServer::HttpServer.new(webrick_options)
        end

        require_sub __FILE__
      end
    end
  end
end
