module ApiLayers
  module Validators
    module Generic
      class RecordPresenceValidator < Base

        def initialize(model_class, record, identifier)
          self.model_class = model_class
          self.record = record
          self.identifier = identifier
        end

        def validation_error_classes
          [
            error_class
          ]
        end

        def validate!
          raise_record_not_found_error if record.blank?

          true
        end

        private

        attr_accessor :model_class, :record, :identifier

        def error_class_name
          @error_class_name ||= model_class.to_s + "NotFoundError"
        end

        def scoped_error_class_name
          @scoped_error_class_name ||= self.class.name + "::" + error_class_name
        end

        def error_class
          return scoped_error_class_name.constantize if self.class.const_defined?(error_class_name)

          self.class.const_set(error_class_name, Class.new(StandardError))

          scoped_error_class_name.constantize
        end

        def raise_record_not_found_error
          raise error_class, "No record found with identifier: #{identifier}"
        end

      end
    end
  end
end
