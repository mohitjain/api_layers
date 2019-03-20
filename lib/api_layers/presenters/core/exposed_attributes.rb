module ApiLayers
  module Presenters
    module Core
      module ExposedAttributes

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods

          def default_exposed_attributes(args = [])
            @_default_exposed_attributes ||= []
            return @_default_exposed_attributes if args.blank?

            @_default_exposed_attributes.push(args).flatten!.collect(&:to_sym).uniq!
          end

          def exposed_attributes(args = [])
            @_exposed_attributes ||= []
            return @_exposed_attributes if args.blank?

            @_exposed_attributes.push(args).flatten!.collect(&:to_sym).uniq!
          end

          def all_exposed_attributes
            ((@_default_exposed_attributes || []) + (@_exposed_attributes || [])).uniq
          end

          def desired_attributes(attributes = nil)
            attributes ||= :default
            if attributes == :default
              @_default_exposed_attributes || []
            elsif attributes == :all
              all_exposed_attributes
            else
              ((@_default_exposed_attributes || []) +
                ((@_exposed_attributes || []) & attributes.collect(&:to_sym))).uniq
            end
          end
        end

        def data_hash
          return {} if data.blank?

          object_data = {}
          desired_attributes = self.class.desired_attributes(data.api_attributes)
          desired_attributes.each do |attribute|
            object_data[attribute] = data.public_send(attribute)
          end
          return object_data unless root_node

          { self.class::ROOT_NODE.to_sym => object_data }
        end
      end
    end
  end
end
