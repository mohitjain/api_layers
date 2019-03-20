RSpec::Matchers.define :be_private do
  match do |attribute|
    described_class.private_instance_methods(false).include?(attribute) &&
      !described_class.public_instance_methods.include?(attribute)
  end
end
