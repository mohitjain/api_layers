module ApiLayers
  module Abstractable

    private

    def check_for_abstract_class_initialization!(base_class)
      raise_abtract_class_initialization_error if self.class == base_class
    end

    def raise_abtract_class_initialization_error
      raise(
        AbstractClassInitializationError,
        "Cannot instantiate abstract class '#{self.class.name}'"
      )
    end
  end
end
