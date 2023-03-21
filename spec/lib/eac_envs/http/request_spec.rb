# frozen_string_literal: true

require 'eac_envs/http/error'
require 'eac_envs/http/request'
require 'eac_envs/http/rspec/echo_server'

::RSpec.describe ::EacEnvs::Http::Request do
  let(:http_server) { ::EacEnvs::Http::Rspec::EchoServer.http }

  around { |example| http_server.on_active(&example) }

  before do
    allow_any_instance_of(::Faraday::Multipart::Middleware).to( # rubocop:disable RSpec/AnyInstance
      receive(:unique_boundary)
      .and_return('-----------RubyMultipartPost-0123456789abcdef0123456789abcdef')
    )
  end

  include_examples 'source_target_fixtures', __FILE__

  def source_data(source_file)
    remove_variable_values(
      ::JSON.parse(
        ::RequestBuilder.from_file(http_server.root_url, source_file).result.response.body_str
      )
    )
  end

  def remove_variable_values(obj)
    if obj.is_a?(::Hash)
      remove_variable_values_from_hash(obj)
    elsif obj.is_a?(::Enumerable)
      remove_variable_values_from_enumerable(obj)
    end
    obj
  end

  def remove_variable_values_from_hash(hash)
    %w[host hostname ip].each { |key| hash.delete(key) }
    hash.each_value { |value| remove_variable_values(value) }
  end

  def remove_variable_values_from_enumerable(enumerable)
    enumerable.each { |value| remove_variable_values(value) }
  end

  context 'with self signed https server' do
    let(:http_server) { ::EacEnvs::Http::Rspec::EchoServer.https }
    let(:instance) { described_class.new.url(http_server.root_url + '/any/path') }
    let(:response_body) { request.response.body_str }

    context 'when no additional flag' do
      let(:request) { instance }

      it do
        expect { response_body }.to(raise_error(::EacEnvs::Http::Error))
      end
    end

    context 'when ssl_verify disabled' do
      let(:request) { instance.ssl_verify(false) }

      it do
        expect { response_body }.not_to raise_error
      end
    end
  end
end
