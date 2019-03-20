module ApiLayers
  module Services
    module Generic
      class Show < Base

        attr_accessor :config_object

        def initialize(request = nil, config_object = nil)
          self.config_object = config_object

          super(request)
        end

        def execute!
          validate_request!

          record_data
        end

        def validation_error_classes
          record_presence_validator.validation_error_classes
        end

        private

        def validate_request!
          record_presence_validator.validate!
        end

        def record_presence_validator
          @record_presence_validator ||= ApiLayers::Validators::Generic::RecordPresenceValidator.new(
            config_object.model_class, record, record_identifier
          )
        end

        def record_identifier
          params[:id]
        end

        def record
          @record ||= find_record
        end

        def find_record
          return @record if defined?(@record) && @record.present?
          config_object.identifier_column_names.each do |column_name|
            @record = config_object.model_class.eager_load(
              includes_scope
            ).where(column_name.to_s => record_identifier).first
            break if @record.present?
          end
          @record
        end

        def record_data
          DataClasses::Generic::RecordData.new(config_object, record)
        end

      end
    end
  end
end
