module ApiLayers
  module Validators
    class Base

      include Abstractable
      include AccessControlable

      def initialize(*args)
        check_for_abstract_class_initialization!(Base)
      end

      def validation_error_classes
        raise NotImplementedError
      end

      def validate!
        raise NotImplementedError
      end

    end
  end
end
