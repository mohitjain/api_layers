module ApiLayers
  module Errors
    class Base < StandardError

      attr_accessor :data_hash

    end
  end
end
