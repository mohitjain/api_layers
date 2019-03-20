module ApiLayers
  module DataClasses
    module Generic
      class RecordData < Base

        attr_accessor :config, :record, :api_attributes

        def initialize(config, record)
          self.config = config
          self.record = record

          instance_eval do
            config.param_property_mapping.each do |param_name, property_name|
              define_method(param_name) do
                record.public_send(property_name)
              end
            end
          end
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
end
