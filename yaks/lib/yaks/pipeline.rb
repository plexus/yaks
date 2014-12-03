module Yaks
  class Pipeline
    include Concord.new(:steps)

    def call(input, env)
      steps.inject(input) {|memo, (_, step)| step.call(memo, env) }
    end

    def insert_hooks(hooks)
      new_steps = hooks.inject(steps) do |steps, (type, target_step, name, hook)|
        steps.flat_map do |step_name, callable|
          if step_name.equal? target_step
            case type
            when :before
              [[name, hook], [step_name, callable]]
            when :after
              [[step_name, callable], [name, hook]]
            when :around
              [[name, ->(x, env) { hook.call(x, env, &callable) }]]
            when :skip
              []
            end
          end || [[step_name, callable]]
        end
      end

      self.class.new(new_steps)
    end

  end
end
