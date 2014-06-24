require 'spec_helper'


RSpec.describe Yaks::FP::Updatable do
  let(:klz) do
    Class.new do
      include Equalizer.new(:aa, :bb, :cc)
      include Yaks::FP::Updatable.new(:aa, :bb, :cc)

      attr_reader :aa, :bb, :cc
      private :aa

      def initialize(aa, bb, cc)
        @aa, @bb, @cc = aa, bb, cc
      end
    end
  end

  it 'should only updated the selected fields' do
    expect(klz.new(1,2,3).update(bb: 7, cc: 9)).to eq klz.new(1,7,9)
  end
end
