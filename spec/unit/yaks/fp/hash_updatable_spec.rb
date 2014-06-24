require 'spec_helper'


RSpec.describe Yaks::FP::HashUpdatable do
  let(:klz) do
    Class.new do
      include Equalizer.new(:aa, :bb, :cc)
      include Yaks::FP::HashUpdatable.new(:aa, :bb, :cc)

      attr_reader :aa, :bb, :cc
      private :aa

      def initialize(opts)
        @aa, @bb, @cc = opts.values_at(:aa, :bb, :cc)
      end
    end
  end

  it 'should only updated the selected fields' do
    expect(klz.new(aa: 1, bb: 2, cc: 3).update(bb: 7, cc: 9)).to eq klz.new(aa: 1, bb: 7, cc: 9)
  end
end
