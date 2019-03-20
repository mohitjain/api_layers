module ApiLayers
  class ServiceCommandExecutor

    attr_reader :service_class, :service_object, :response_class, :request, :config_object

    def initialize(
      service_class:, request:, response_class:, data_presenter_class: nil, config_object: nil
    )
      self.service_class = service_class
      self.request = request
      self.response_class = response_class
      self.data_presenter_class = data_presenter_class
      self.config_object = config_object
      self.service_object = create_service_object
    end

    def execute
      result_data = service_object.execute!
      success_response(result_data)
    rescue *validation_error_classes => error
      log_error(error)

      return error_response(
        error: error, error_message: error_message(error), unexpected_error: false
      )
    rescue StandardError => error
      log_error(error)
      log_error_in_sentry(error)
      raise error if Rails.env.development?

      return error_response(error: error)
    end

    def data_presenter_class
      return null_presenter_class unless @data_presenter_class.is_a?(Class)

      @data_presenter_class
    end

    # TODO: Move factory methods to a separate factory class
    # Factory method to create data presenter object
    def data_presenter_object(result_data)
      if config_object.present? && config_object.is_a?(ActionConfigurations::Collection)
        # Generic::CollectionPresenter
        data_presenter_class.new(data: result_data, request: request, config_object: config_object)
      elsif config_object.present? && config_object.is_a?(ActionConfigurations::Show)
        # Generic::ShowPresenter
        data_presenter_class.new(data: result_data, request: request, config_object: config_object)
      else
        data_presenter_class.new(data: result_data, request: request)
      end
    end

    private

    attr_writer :service_class, :service_object, :response_class, :data_presenter_class, :request,
                :config_object

    # Factory method to create service object
    def create_service_object
      if service_class.parents.include?(ApiLayers::Services::Generic)
        service_class.new(request, config_object)
      else
        service_class.new(request)
      end
    end

    def log_error(error)
      Rails.logger.error "[#{self.class.name}] #{error.class.name}: " + error.message
    end

    def log_error_in_sentry(error)
      Raven.capture_exception(error, level: 'warning')
    end

    def error_message(error)
      if active_record_validation_error?(error)
        error.record.errors.full_messages.first
      else
        error.message
      end
    end

    def active_record_validation_error?(error)
      active_record_validation_errors.each do |error_class|
        return true if error.is_a?(error_class)
      end

      false
    end

    def active_record_validation_errors
      [
        ActiveRecord::RecordInvalid,
        ActiveRecord::RecordNotSaved
      ]
    end

    def validation_error_classes
      service_object.validation_error_classes.flatten + active_record_validation_errors
    end

    def success_response(result_data)
      response_class.new(data: data_hash(result_data))
    end

    def data_hash(result_data)
      data_presenter_object(result_data).data_hash
    end

    def error_response(error: nil, error_message: nil, unexpected_error: true)
      response_class.new(
        error: error, error_message: error_message, data: data_hash_from_error(error),
        unexpected_error: unexpected_error
      )
    end

    def data_hash_from_error(error)
      error.data_hash if error.respond_to?(:data_hash)
    end

    def null_presenter_class
      Presenters::NullPresenter
    end
  end
end
