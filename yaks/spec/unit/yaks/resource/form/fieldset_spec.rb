RSpec.describe Yaks::Resource::Form::Fieldset do
  subject(:fieldset) { described_class.new(fields: []) }

  describe '#type' do
    its(:type) { should equal :fieldset }
  end
end
