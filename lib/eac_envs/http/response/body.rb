# frozen_string_literal: true

require 'eac_ruby_utils/core_ext'
require 'json'

module EacEnvs
  module Http
    class Response < ::StandardError
      module Body
        delegate :response_body_data_proc, to: :request

        def body_data
          r = body_data_method_name.if_present(body_str) do |v|
            respond_to?(v, true) ? send(v) : body_str
          end
          r = response_body_data_proc.call(r) if response_body_data_proc.present?
          r
        end

        # @return [Object]
        # @raise [EacEnvs::Http::Response]
        def body_data!
          raise_unless_200

          body_data
        end

        # @deprecated Use {#body_data!} instead.
        # @return [Object]
        # @raise [EacEnvs::Http::Response]
        def body_data_or_raise
          body_data!
        end

        # @return [String]
        def body_str
          performed.body
        end

        def body_str_or_raise
          raise_unless_200

          body_str
        end

        # @param path [Pathname]
        def write_body(path)
          ::File.binwrite(path, performed.body)
        end

        private

        def body_data_from_application_json
          ::JSON.parse(body_str)
        end

        def body_data_from_application_xml
          Hash.from_xml(body_str)
        end

        # @return [String]
        def body_data_method_name
          content_type.if_present do |v|
            "body_data_from_#{v.split(';').first.force_encoding(::Encoding::UTF_8).variableize}"
          end
        end
      end
    end
  end
end
