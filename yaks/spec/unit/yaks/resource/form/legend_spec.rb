RSpec.describe Yaks::Resource::Form::Legend do
  subject(:legend) { described_class.new(label: 'a legend') }

  describe '#initialize' do
    its(:type) { should equal :legend }
    its(:label) { should eql 'a legend' }
  end
end
