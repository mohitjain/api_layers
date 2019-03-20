module ApiLayers
  module Presenters
    module Generic
      class CollectionPresenter < Base

        include Collectionable

        # Don't forget to set ROOT_NODE for now

        attr_accessor :config_object

        def initialize(data: nil, request: nil, root_node: true, config_object: nil)

          self.config_object = config_object

          collection_presenter_for(config_object.presenter_class)

          super(data: data, request: request, root_node: root_node)
        end

      end
    end
  end
end
