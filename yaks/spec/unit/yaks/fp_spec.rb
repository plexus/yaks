RSpec.describe Yaks::FP do
  include described_class

  describe '#curry_method' do
    def method_3args(a,b,c)
      "#{a}-#{b}-#{c}"
    end

    it 'should curry the method' do
      expect(curry_method(:method_3args).(1).(2,3)).to eql "1-2-3"
    end
  end

  describe '#send_with_args' do
    it 'should bind the arguments' do
      expect(send_with_args(:+, 'foo').('bar')).to eql 'barfoo'
    end

    it 'should bind the block' do
      expect(send_with_args(:map) {|x| x.upcase }.(['bar'])).to eql ['BAR']
    end
  end

  describe '#identity_function' do
    it 'should return whatever you pass it' do
      expect(identity_function.(:foo)).to equal :foo
    end
  end
end
