RSpec.describe Yaks::Pipeline do
  subject(:pipeline) { described_class.new(steps) }
  let(:steps) {
    [
      [:step1, ->(i, _e) { i + 1 }],
      [:step2, ->(i, _e) { i + 10 }],
      [:step3, ->(i, e) { i + e[:foo] }],
    ]
  }
  let(:env) {{ foo: 100 }}

  describe '#call' do
    it 'should call steps in turn, passing in the last result and env' do
      expect(pipeline.call(1000, env)).to equal 1111
    end
  end

  describe '#insert_hooks' do
    let(:hooks)   { [] }

    describe 'before' do
      let(:hooks) { [[:before, :step2, :before_step2, ->(i, _e) { i - (i % 100) }]] }

      it 'should insert a hook before the step' do
        expect(pipeline.insert_hooks(hooks).call(1000, env)).to equal 1110
      end
    end

    describe 'after' do
      let(:hooks) { [[:after, :step2, :after_step2, ->(i, _e) { i - (i % 100) }]] }

      it 'should insert a hook after the step' do
        expect(pipeline.insert_hooks(hooks).call(1000, env)).to equal 1100
      end
    end

    describe 'around' do
      let(:hooks) { [[:around, :step2, :after_step2, ->(i, e, &b) { e[:foo] + b[i, e] + b[i, e] }]] }

      it 'should insert a hook after the step' do
        expect(pipeline.insert_hooks(hooks).call(1000, env)).to equal 2222
      end
    end

    describe 'skip' do
      let(:hooks) { [[:skip, :step2 ]] }

      it 'should insert a hook after the step' do
        expect(pipeline.insert_hooks(hooks).call(1000, env)).to equal 1101
      end
    end

    describe 'multiple hooks' do
      let(:hooks) {
        [
          [:after, :step2, :after_step2, ->(i, _e) { i % 10 }],
          [:skip, :step3]
        ]
      }

      it 'should insert the hooks' do
        expect(pipeline.insert_hooks(hooks).call(1000, env)).to equal 1
      end
    end

    it 'should return a pipeline with the right step names' do
      expect(pipeline
              .insert_hooks([[:before, :step2, :step1_1, ->(i, _e) { i + 1 }]])
              .insert_hooks([[:before, :step1_1, :step1_0, ->(i, _e) { i + 10 }]])
              .insert_hooks([[:after,  :step1_1, :step1_2, ->(i, _e) { i + 100 }]])
              .insert_hooks([[:around, :step1_1, :step1_1_0, ->(i, e, &b) { b.call(i, e) + 1000 }]])
              .insert_hooks([[:around, :step1_2, :step1_3, ->(i, e, &b) { b.call(i, e) + 1000 }]])
              .insert_hooks([[:after,  :step1_3, :step1_4, ->(i, _e) { i + 10_000 }]])
              .call(1000, env)
            ).to equal 13_222
    end
  end

  let(:fake_step) {
    Class.new do
      include Attribs.new(:transitive, :call, inverse: nil)
      alias_method :transitive?, :transitive
    end
  }

  let(:transitive_step) {
    fake_step.new(transitive: true, inverse: ->(_x, _env) {}, call: "t")
  }

  let(:intransitive_step) {
    fake_step.new(transitive: false, call: "i")
  }

  subject(:pipeline) { described_class.new(steps) }

  describe '#transitive?' do
    context 'with transitive steps' do
      let(:steps) { [[:name1, transitive_step]] }
      it 'should be transitive' do
        expect(pipeline.transitive?).to be true
      end
    end
  end

  describe '#inverse' do
  end
end

# describe 'after' do
#   let(:hooks) { proc { after(:format) { :after_format_impl } } }

#   it 'should insert a hook after the step' do
#     expect(runner.steps.map(&:first)).to eql [
#       :map, :format, :after_format, :primitivize, :serialize
#     ]
#     expect(runner.steps[1].last).to be runner.formatter
#     expect(runner.steps[2].last.call).to be :after_format_impl
#   end
# end

# describe 'around' do
#   let(:hooks) do
#     proc {
#       around(:serialize) do |res, env, &block|
#         "serialized[#{env}][#{block.call(res, env)}]"
#       end
#     }
#   end

#   it 'should insert a hook around the step' do
#     expect(runner.steps.map(&:first)).to eql [
#       :map, :format, :primitivize, :serialize
#     ]
#     expect(runner.steps.assoc(:serialize).last.call(["res1"], "env1")).to eql(
#       "serialized[env1][[\n  \"res1\"\n]]"
#     )
#   end
# end

# describe 'around' do
#   let(:hooks) { ->(*) { skip(:serialize) } }

#   it 'should skip a certain step' do
#     expect(runner.steps.map(&:first)).to eql [
#       :map, :format, :primitivize
#     ]
#   end
# end

# describe 'multiple hooks' do
#   let(:hooks) {
#     proc {
#       after(:format) { :after_format_impl }
#       skip(:serialize)
#     }
#   }

#   it 'should insert the hooks' do
#     expect(runner.steps.map(&:first)).to eql [
#       :map, :format, :after_format, :primitivize
#     ]
#   end

#   it 'should pass on unchanged steps' do
#     expect(runner.steps.assoc(:map)[1]).to eql runner.mapper
#   end
# end
