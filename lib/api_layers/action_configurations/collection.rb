module ApiLayers
  module ActionConfigurations
    class Collection < Show

      def default_root_node_name
        model_class.name.underscore.pluralize.to_sym
      end

    end
  end
end
