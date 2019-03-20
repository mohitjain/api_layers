module ApiLayers
  module GenericActions

    def index
      response = ApiLayers::ServiceCommandExecutor.new(
        service_class: ApiLayers::Services::Generic::Collection,
        request: api_request_object,
        response_class: ApiLayers::Responses::Base,
        data_presenter_class: ApiLayers::Presenters::Generic::CollectionPresenter,
        config_object: index_config_object
      ).execute

      render(response.to_hash)
    end

    def show
      response = ApiLayers::ServiceCommandExecutor.new(
        service_class: ApiLayers::Services::Generic::Show,
        request: api_request_object,
        response_class: ApiLayers::Responses::Base,
        data_presenter_class: ApiLayers::Presenters::Generic::ShowPresenter,
        config_object: show_config_object
      ).execute

      render(response.to_hash)
    end

    private

    def index_config_object
      raise "Please define index_config_object for #{self.class.name}"
      # ApiLayers::ActionConfigurations::Collection.new do |config|
      #   config.model_class = TravelAgent
      #   config.default_exposed_attributes = [:id, :name]
      # end
    end

    def show_config_object
      raise "Please define show_config_object for #{self.class.name}"
      # ApiLayers::ActionConfigurations::Show.new do |config|
      #   config.model_class = TravelAgent
      #   config.default_exposed_attributes = [:id, :name]
      # end
    end

  end
end
