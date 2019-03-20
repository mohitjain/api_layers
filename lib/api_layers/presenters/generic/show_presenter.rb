module ApiLayers
  module Presenters
    module Generic
      class ShowPresenter < Base

        attr_accessor :config_object

        def initialize(data: nil, request: nil, root_node: true, config_object: nil)
          self.config_object = config_object

          super(data: data, request: request, root_node: root_node)
        end

        def data_hash
          config_object.presenter_class.new(
            data: data, request: request, root_node: root_node
          ).data_hash
        end

      end
    end
  end
end
