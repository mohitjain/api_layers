# Abstract Base class for API Data Presenters
#
# DO NOT:
# - initialize this class
# - add custom code to this class(this class must remain generic)
#
# Create and use classes derived from this class.
#
# Derived classes must implement:
# - data_hash instance method

module ApiLayers
  module Presenters
    class Base

      include Abstractable
      include Core::ExposedAttributes

      attr_reader :data, :request, :root_node

      def initialize(data: nil, request: nil, root_node: true)
        check_for_abstract_class_initialization!(Base)
        self.data = data
        self.request = request
        self.root_node = root_node
      end

      protected

      attr_writer :data, :request, :root_node

      def additional_field_present?(additional_field_name)
        request.additional_field_present?(additional_field_name)
      end

      def wrap_in_root_node(data_hash)
        return data_hash unless root_node

        { self.class::ROOT_NODE => data_hash }
      end
    end
  end
end
