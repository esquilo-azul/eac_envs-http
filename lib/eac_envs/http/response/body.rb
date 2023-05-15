# frozen_string_literal: true

require 'eac_ruby_utils/core_ext'
require 'json'

module EacEnvs
  module Http
    class Response < ::StandardError
      module Body
        delegate :response_body_data_proc, to: :request

        def body_data
          r = performed.headers['Accept'].if_present(body_str) do |v|
            method_name = "body_data_from_#{v.parameterize.underscore}"
            respond_to?(method_name) ? send(method_name) : body_str
          end
          r = response_body_data_proc.call(r) if response_body_data_proc.present?
          r
        end

        def body_data_or_raise
          raise_unless_200

          body_data
        end

        # @return [String]
        def body_str
          performed.body
        end

        def body_str_or_raise
          raise_unless_200

          body_str
        end

        private

        def body_data_from_application_json
          ::JSON.parse(body_str)
        end

        def body_data_from_application_xml
          Hash.from_xml(body_str)
        end
      end
    end
  end
end
