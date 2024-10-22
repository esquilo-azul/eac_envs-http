# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'eac_envs/http/version'

Gem::Specification.new do |s|
  s.name        = 'eac_envs-http'
  s.version     = EacEnvs::Http::VERSION
  s.authors     = ['Put here the authors']
  s.summary     = 'Put here de description.'

  s.files = Dir['{lib}/**/*']
  s.required_ruby_version = '>= 2.7'

  s.add_dependency 'eac_fs', '~> 0.18', '>= 0.18.1'
  s.add_dependency 'eac_ruby_utils', '~> 0.123'
  s.add_dependency 'faraday', '~> 2.8', '>= 2.8.1'
  s.add_dependency 'faraday-follow_redirects', '~> 0.3'
  s.add_dependency 'faraday-gzip', '~> 0.1'
  s.add_dependency 'faraday-multipart', '~> 1.0', '>= 1.0.4'
  s.add_dependency 'faraday-retry', '~> 2.2', '>= 2.2.1'
  s.add_dependency 'random-port', '~> 0.7', '>= 0.7.1'

  s.add_development_dependency 'eac_ruby_gem_support', '~> 0.10'
end
