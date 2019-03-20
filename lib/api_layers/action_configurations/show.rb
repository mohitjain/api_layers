# Add documentation for config creation

module ApiLayers
  module ActionConfigurations
    class Show < Base

      attr_accessor(
        :model_class,
        :presenter_class,
        :identifier_column_names,
        :param_property_mapping,
        :enable_filters,
        :slave_read,
        :additional_fields_mappings,
        :default_includes
      )

      def initialize
        # default_exposed_attributes:, exposed_attributes: [], identifier_column_names: [:id],
        # param_property_mapping: {}

        config = OpenStruct.new
        yield config

        # TODO: Validate config attributes

        self.model_class = config.model_class
        self.presenter_class = config.presenter_class || default_presenter_class
        self.identifier_column_names = config.identifier_column_names || [:id]
        self.param_property_mapping = config.param_property_mapping || {}
        self.enable_filters = config.enable_filters
        self.slave_read = config.slave_read || true
        self.default_includes = (config.default_includes || []).collect(&:to_sym)
        self.additional_fields_mappings = filtered_additional_fields_mappings(
          config.additional_fields_mappings
        )
      end


      def filtered_additional_fields_mappings(additional_fields_mappings)
        return {} if additional_fields_mappings.blank?

        converted_hash = {}
        additional_fields_mappings.each do |element|
          add_to_fields_mappings_hash!(converted_hash, element)
        end
        converted_hash
      end

      def add_to_fields_mappings_hash!(converted_hash, element)
        if element.is_a?(Hash)
          element.each do |key, value|
            converted_hash.merge!(key.to_sym => value)
          end
        elsif [String, Symbol].include?(element.class)
          converted_hash.merge!(element.to_s.to_sym => element)
        end
      end

      def default_root_node_name
        model_class.name.underscore.to_sym
      end

      def default_presenter_class
        "Api::CrsV1::Presenters::#{model_class}Presenters::ShowPresenter".constantize
      end

    end
  end
end
