RSpec::Matchers.define :be_protected do
  match do |attribute|
    described_class.protected_instance_methods(false).include?(attribute) &&
      !described_class.public_instance_methods.include?(attribute)
  end
end
