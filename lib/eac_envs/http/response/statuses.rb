# frozen_string_literal: true

require 'eac_ruby_utils/core_ext'

module EacEnvs
  module Http
    class Response < ::StandardError
      module Statuses
        def raise_unless_200
          return nil if status == 200

          raise self
        end

        def status
          performed.status.to_i
        end
      end
    end
  end
end
