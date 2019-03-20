module ApiLayers
  module Presenters
    module Collectionable

      attr_accessor :item_presenter_class

      def collection_presenter_for(item_presenter_class)
        self.item_presenter_class = item_presenter_class
      end

      def data_hash
        return collection_data_hash_array unless root_node

        collection_data_hash
      end

      protected

      def collection_data_hash_array
        data.map do |data_item|
          item_presenter_object(data_item).data_hash
        end
      end

      def item_presenter_object(data_item)
        if item_presenter_class.parents.include?(ApiLayers::Presenters::Generic)
          item_presenter_class.new(
            data: data_item,
            request: request,
            root_node: false,
            config_object: config_object
          )
        else
          item_presenter_class.new(
            data: data_item,
            request: request,
            root_node: false
          )
        end
      end

      def collection_data_hash
        data_hash = {
          config_object.presenter_class::ROOT_NODE.to_s.pluralize => collection_data_hash_array
        }

        set_bulk_action_status!(data_hash)

        data_hash.merge!(pagination: data.pagination_hash) if data.pagination_hash.present?

        data_hash
      end

      def set_bulk_action_status!(_data_hash)

      end

    end
  end
end
