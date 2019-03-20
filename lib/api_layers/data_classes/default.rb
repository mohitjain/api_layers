module ApiLayers
  module DataClasses
    class Default < Base

      attr_accessor :record, :api_attributes

      def initialize(record)
        self.record = record
      end

      def method_missing(method_name, *args, &block)
        if record.respond_to?(method_name)
          record.public_send(method_name, *args, &block)
        else
          super
        end
      end

    end
  end
end
