# frozen_string_literal: true

require 'eac_ruby_utils/core_ext'
require 'eac_ruby_utils/fs/temp'
require 'eac_ruby_utils/yaml'

class RequestBuilder
  class << self
    def from_file(root_url, path)
      new(root_url, ::EacRubyUtils::Yaml.load_file(path))
    end
  end

  FILE_FIELD_PARSER = /\A@(.+)\z/.to_parser { |m| m[1] }

  common_constructor :root_url, :data do
    self.root_url = root_url.to_uri
    self.data = data.with_indifferent_access
  end

  def new_request
    ::EacEnvs::Http::Request.new.url(root_url + data.fetch(:url_suffix))
  end

  def result
    r = %i[verb headers].inject(new_request) do |a, e|
      data[e].if_present(a) { |v| a.send(e, v) }
    end
    result_body_data(result_auth(r))
  end

  def build_body_data(source)
    return source unless source.is_a?(::Hash)

    source.map { |k, v| build_body_field(k, v) }
  end

  def build_body_field(name, value)
    FILE_FIELD_PARSER.parse(name).if_present([name, value]) do |v|
      [v, file_with_value(value)]
    end
  end

  def file_with_value(value)
    r = ::EacRubyUtils::Fs::Temp.directory.join('basename')
    r.write(value)
    ::File.new(r.to_path)
  end

  private

  def result_auth(request)
    request = data[:auth].if_present(request) do |v|
      request.basic_auth(v.fetch(:username), v.fetch(:password))
    end
  end

  def result_body_data(request)
    data[:body_data].if_present(request) { |v| request.body_data(build_body_data(v)) }
  end
end
