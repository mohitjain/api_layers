# Abstract Base class for API Service Actions
#
# DO NOT:
# - initialize this class
# - add custom code to this class(this class must remain generic)
#
# Create and use classes derived from this class.
#
# Derived classes must implement:
# - execute instance method
# - validation_error_classes instance method: must return an
#     array of validation error classes

module ApiLayers
  module Services
    class Base

      include Abstractable
      include AccessControlable

      extend Forwardable

      class LoggedInUserMissingError < StandardError; end

      attr_reader :request

      def initialize(request = nil)
        check_for_abstract_class_initialization!(Base)

        self.request = request
      end

      def execute!
        raise NotImplementedError
      end

      def validation_error_classes
        raise NotImplementedError
      end

      def_delegators :request, :params, :current_user

      def filter_params
        params[:filters]
      end

      protected

      attr_writer :request

      def validate_current_user!
        raise_logged_in_user_missing_error if request.current_user.blank?
      end

      def raise_logged_in_user_missing_error
        raise LoggedInUserMissingError, 'Current logged in user is missing'
      end

      def includes_scope
        (config_object.additional_fields_mappings.values_at(
            *request.additional_fields.collect(&:to_sym)
          ).compact +
          config_object.default_includes
        ).uniq
      end

    end
  end
end
