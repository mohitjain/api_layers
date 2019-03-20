module ApiLayers
  module DataClasses
    module Collectionable

      attr_accessor :data_collection, :pagination_hash, :bulk_action_success

      def map
        data_collection.map do |data_item|
          yield(data_item)
        end
      end

    end
  end
end
