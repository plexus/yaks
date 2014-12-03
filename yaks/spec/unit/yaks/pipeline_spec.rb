RSpec.describe Yaks::Pipeline do
  subject(:pipeline) { described_class.new(steps) }
  let(:steps) {
    [
      [:step1, ->(i, e) { i + 1 }],
      [:step2, ->(i, e) { i + 10 }],
      [:step3, ->(i, e) { i + e[:foo] }],
    ]
  }
  let(:env) {{ foo: 100 }}

  describe '#call' do
    it 'should call steps in turn, passing in the last result and env' do
      expect(pipeline.call(1000, env)).to eql 1111
    end
  end

  # describe '#insert_hooks' do
  #   let(:options) { { mapper: Yaks::Mapper } }
  #   let(:config)  { Yaks.new(&hooks) }
  #   let(:hooks)   { proc {} }

  #   describe 'before' do
  #     let(:hooks) { proc { before(:map) { :before_map_impl } } }

  #     it 'should insert a hook before the step' do
  #       expect(runner.steps.map(&:first)).to eql [
  #         :before_map, :map, :format, :primitivize, :serialize
  #       ]
  #       expect(runner.steps[0].last.call).to be :before_map_impl
  #       expect(runner.steps[1].last).to be runner.mapper
  #     end
  #   end

  #   describe 'after' do
  #     let(:hooks) { proc { after(:format) { :after_format_impl } } }

  #     it 'should insert a hook after the step' do
  #       expect(runner.steps.map(&:first)).to eql [
  #         :map, :format, :after_format, :primitivize, :serialize
  #       ]
  #       expect(runner.steps[1].last).to be runner.formatter
  #       expect(runner.steps[2].last.call).to be :after_format_impl
  #     end
  #   end

  #   describe 'around' do
  #     let(:hooks) do
  #       proc {
  #         around(:serialize) do |res, env, &block|
  #           "serialized[#{env}][#{block.call(res, env)}]"
  #         end
  #       }
  #     end

  #     it 'should insert a hook around the step' do
  #       expect(runner.steps.map(&:first)).to eql [
  #         :map, :format, :primitivize, :serialize
  #       ]
  #       expect(runner.steps.assoc(:serialize).last.call(["res1"], "env1")).to eql(
  #         "serialized[env1][[\n  \"res1\"\n]]"
  #       )
  #     end
  #   end

  #   describe 'around' do
  #     let(:hooks) { ->(*) { skip(:serialize) } }

  #     it 'should skip a certain step' do
  #       expect(runner.steps.map(&:first)).to eql [
  #         :map, :format, :primitivize
  #       ]
  #     end
  #   end

  #   describe 'multiple hooks' do
  #     let(:hooks) {
  #       proc {
  #         after(:format) { :after_format_impl }
  #         skip(:serialize)
  #       }
  #     }

  #     it 'should insert the hooks' do
  #       expect(runner.steps.map(&:first)).to eql [
  #         :map, :format, :after_format, :primitivize
  #       ]
  #     end

  #     it 'should pass on unchanged steps' do
  #       expect(runner.steps.assoc(:map)[1]).to eql runner.mapper
  #     end
  #   end

  # end
end
