class TestRecord < ActiveMocker::Base
  def self.abstract_class?
    false
  end

  def self.human_attribute_name(a, b)
    return a.to_s
  end

  def self.i18n_scope

  end
end
