module Rulesy
  module Definition
    @@rule_definitions ||= {}

    def rule_definitions
      @@rule_definitions
    end

    def define_rules_for(name, &block)
      unless included_modules.include?(InstanceMethods)
        include InstanceMethods
      end

      rule_definitions[name] = block
    end

    module InstanceMethods

      def rule(name, message = 'is invalid.', &block)
        value = instance_eval &block
        self.business_rules_errors.merge!({name => message}) unless value
      end

      def business_rules_errors(reload = false)
        @business_rules_errors = nil if reload
        @business_rules_errors ||= {}
      end

      def business_rules_errors=(val)
        @business_rules_errors = val
      end

      def rule_definitions
        self.class.rule_definitions
      end

      # def can_display
      # validate_business_rules(:can_display)
      # end
      # alias_method :can_display?, :can_display

      def method_missing(method_id, *args)
        method_name = method_id.to_s.gsub(/\?/, '').to_sym
        if self.rule_definitions.key?(method_name)
          instance_variable_set( "@#{method_name}", self.validate_business_rules(method_name)) if instance_variable_get( "@#{method_name}" ).nil?
        else
          super
        end
      end

      protected
      # This method accepts two parameters: a name for the type of business rules being validated (used for the business_rules_errors hash)
      # And a hash where the key is the object and the value is the method being called on the object.
      def validate_business_rules(rules_type)
        self.business_rules_errors = {}

        instance_eval &rule_definitions[rules_type]

        self.business_rules_errors.empty?
      end
    end
  end
end