module ApiLayers
  module Responses
    class UnprocessableEntity < Base

      def success_status
        :unprocessable_entity
      end

    end
  end
end

