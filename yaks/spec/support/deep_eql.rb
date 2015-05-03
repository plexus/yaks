# When comparing deep nested structures, it can be really hard to figure out what
# the actual differences are looking at the RSpec output. This custom matcher
# traverses nested hashes and arrays recursively, and reports each difference
# separately, with a JSONPath string of where the difference was found
#
# e.g.
#
# at $.shows[0].venues[0].name, got Foo, expected Bar

module Matchers
  class DeepEql
    extend Forwardable
    attr_reader :expectation, :stack, :target, :diffs, :result
    def_delegators :stack, :push, :pop

    def initialize(expectation, stack = [], diffs = [])
      @expectation = expectation
      @stack       = stack
      @diffs       = diffs
      @result      = true
    end

    def description
      'be deeply equal'
    end

    def recurse(target, expectation)
      # leave this in two lines so it doesn't short circuit
      result = DeepEql.new(expectation, stack, diffs).matches?(target)
      @result &&= result
    end

    def stack_as_jsonpath
      '$' + stack.map do |item|
        case item
        when Integer, /\W/
          "[#{item.inspect}]"
        else
          ".#{item}"
        end
      end.join
    end

    def add_failure_message(message)
      diffs << "at %s, %s" % [stack_as_jsonpath, message]
      @result = false
    end

    def compare(key)
      push key
      if target[key] != expectation[key]
        if [Hash, Array].any?{|klz| target[key].is_a? klz }
          recurse(target[key], expectation[key])
        else
          add_failure_message begin
                                if expectation[key].class == target[key].class
                                  "expected #{expectation[key].inspect}, got #{target[key].inspect}"
                                else
                                  "expected #{expectation[key].class}: #{expectation[key].inspect}, got #{target[key].class}: #{target[key].inspect}"
                                end
                              rescue Encoding::CompatibilityError
                                "expected #{expectation[key].encoding}, got #{target[key].encoding}"
                              end
        end
      end
      pop
    end

    def matches?(target)
      @target = target
      case expectation
      when Hash
        if target.is_a?(Hash)
          if target.class != expectation.class # e.g. HashWithIndifferentAccess
            add_failure_message("expected #{expectation.class}, got #{target.class}")
          end
          (expectation.keys - target.keys).each do |key|
            add_failure_message "Expected key #{key.inspect} => #{expectation[key].inspect}"
          end
          (target.keys - expectation.keys).each do |key|
            add_failure_message "Unexpected key #{key.inspect} => #{target[key].inspect}"
          end
          (target.keys & expectation.keys).each do |key|
            compare key
          end
        else
          add_failure_message("expected Hash got #{@target.inspect}")
        end

      when Array
        if target.is_a?(Array)
          0.upto([target.count, expectation.count].max) do |idx|
            compare idx
          end
        else
          add_failure_message("expected Array got #{@target.inspect}")
        end

      else
        if target != expectation
          add_failure_message("expected #{expectation.inspect}, got #{@target.inspect}")
        end
      end

      result
    end

    def failure_message_for_should
      diffs.join("\n")
    end
    alias_method :failure_message, :failure_message_for_should

    def failure_message_for_should_not
      "expected #{@target.inspect} not to be in deep_eql with #{@expectation.inspect}"
    end
    alias_method :failure_message_when_negated, :failure_message_for_should_not
  end
end

module RSpec::Matchers
  def deep_eql(exp)
    Matchers::DeepEql.new(exp)
  end
end
