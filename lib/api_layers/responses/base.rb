# Base Response class
#
# This can be used for simple GET responses.
#
# For custom responses, create derived classes and override the required methods.

module ApiLayers
  module Responses
    class Base

      attr_reader :data, :error, :error_message, :unexpected_error

      def initialize(data: nil, error: nil, error_message: nil, unexpected_error: true)
        self.data = data || {}
        self.error = error
        self.error_message = error_message
        self.unexpected_error = unexpected_error
      end

      def success?
        data.present? && error.blank? && error_message.blank?
      end

      def to_hash
        return success_response_hash if success?
        return unexpected_error_response_hash if error.present? && unexpected_error

        bad_request_response_hash
      end

      def success_status
        :ok
      end

      ACTIVE_RECORD_VALIDATION_ERRORS = [
        ActiveRecord::RecordInvalid,
        ActiveRecord::RecordNotSaved
      ].freeze

      protected

      attr_writer :data, :error, :error_message, :unexpected_error

      def success_response_hash
        {
          json: {
            success: true,
          }.merge(data),
          status: success_status
        }
      end

      def bad_request_response_hash
        {
          json: {
            success: false,
            error: {
              type: 'error',
              message: error_message || 'Bad Request'
            }
          }.deep_merge(error_data),
          status: :bad_request
        }
      end

      def unexpected_error_response_hash
        {
          json: {
            success: false,
            error: {
              type: 'error',
              message: 'Something went wrong'
            }
          },
          status: :internal_server_error
        }
      end

      def error_data
        return active_record_errors_hash if active_record_validation_error?

        data
      end

      def active_record_errors_hash
        {
          errors: error.record.errors,
          full_error_messages: error.record.errors.full_messages
        }
      end

      def active_record_validation_error?
        ACTIVE_RECORD_VALIDATION_ERRORS.each do |error_class|
          return true if error.is_a?(error_class)
        end

        false
      end

    end
  end
end
