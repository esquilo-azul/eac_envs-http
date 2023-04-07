# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'eac_envs/http/version'

Gem::Specification.new do |s|
  s.name        = 'eac_envs-http'
  s.version     = EacEnvs::Http::VERSION
  s.authors     = ['Put here the authors']
  s.summary     = 'Put here de description.'

  s.files = Dir['{lib}/**/*']

  s.add_dependency 'eac_fs', '~> 0.16'
  s.add_dependency 'eac_ruby_utils', '~> 0.112'
  s.add_dependency 'faraday', '~> 2.7', '>= 2.7.4'
  s.add_dependency 'faraday-follow_redirects', '~> 0.3'
  s.add_dependency 'faraday-gzip', '~> 0.1'
  s.add_dependency 'faraday-multipart', '~> 1.0', '>= 1.0.4'
  s.add_dependency 'faraday-retry', '~> 2.1'

  s.add_development_dependency 'aranha-parsers', '~> 0.17'
  s.add_development_dependency 'eac_ruby_gem_support', '~> 0.5', '>= 0.5.1'
end
