# frozen_string_literal: true

require 'addressable'
require 'eac_ruby_utils/core_ext'
require 'random-port'
require 'webrick'
require 'webrick/https'

module EacEnvs
  module Http
    module Rspec
      class EchoServer
        HOSTNAME = 'localhost'
        SCHEMES = {
          http: {},
          https: { SSLEnable: true, SSLCertName: [['CN', HOSTNAME]] }
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
          on_aquired_port do
            http_server.on_running(&block)
          end
        end

        def root_url
          ::Addressable::URI.new(
            scheme: scheme.to_s,
            host: ::EacEnvs::Http::Rspec::EchoServer::HOSTNAME,
            port: port!
          )
        end

        protected

        attr_accessor :port

        # @return [EacEnvs::Http::Rspec::EchoServer::HttpServer]
        def http_server
          ::EacEnvs::Http::Rspec::EchoServer::HttpServer.new(webrick_options.merge(Port: port!))
        end

        def on_aquired_port(&block)
          ::RandomPort::Pool.new.acquire do |port|
            self.port = port
            block.call
            self.port = nil
          end
        end

        # @return [Integer]
        def port!
          port.presence || raise('Port unsetted')
        end

        require_sub __FILE__
      end
    end
  end
end
