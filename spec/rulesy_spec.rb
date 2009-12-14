require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Engine
  extend Rulesy::Definition
  define_rules_for :can_start do
    rule(:has_gas) { has_gas? }
    rule(:has_wheels, "you don't have valid wheels") { has_wheels? }
  end

  def has_gas?
    true
  end

  def has_wheels?
    false
  end
end

describe Rulesy::Definition do

  context "wired up?" do
    it "should have class method define_rules_for" do
      Engine.should respond_to(:define_rules_for)
    end

    it "should have rule_definitions class attr" do
      Engine.should respond_to(:rule_definitions)
    end

    it "should include the InstanceMethods module" do
      Engine.included_modules.should include(Rulesy::Definition::InstanceMethods)
    end
  end

  context "have respond to method defined by rule definition" do
    it "should return false for can_start?"do
      Engine.new.can_start.should be( false )
    end

    it "should have a validation message when validation fails" do
      engine = Engine.new
      engine.can_start?
      engine.business_rules_errors.should_not be_empty
      engine.business_rules_errors.first.should == [:has_wheels, "you don't have valid wheels"]
    end
  end
end
