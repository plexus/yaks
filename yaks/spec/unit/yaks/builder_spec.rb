RSpec.describe Yaks::Builder do
  class Buildable
    include Yaks::Attributes.new(:foo, :bar)

    def self.create(foo, bar)
      new(foo: foo, bar: bar)
    end

    def finalize
      with(foo: 7, bar: 8)
    end

    def wrong_type(x, y)
      "foo #{x} #{y}"
    end
  end

  subject do
    Yaks::Builder.new(Buildable, [:finalize]) do
      def_set :foo, :bar
      def_forward :wrong_type, :update
    end
  end

  it 'should keep state' do
    expect(
      subject.create(3, 4) do
        foo 7
        update bar: 6
      end.to_h
    ).to eql(foo: 7, bar: 6)
  end

  it 'should unwrap again' do
    expect( subject.create(3, 4) { finalize } ).to eql Buildable.new(foo: 7, bar: 8)
  end

  context 'with no methods to forward' do
    subject do
      Yaks::Builder.new(Buildable)
    end

    it 'should still work' do
      expect(subject.create(3,4)).to eql Buildable.new(foo: 3, bar: 4)
    end
  end

  describe '#build' do
    it 'should pass on the initial state if no block is given' do
      expect(subject.build(:foo)).to equal :foo
    end

    it 'should pass any extra args to the block' do
      expect(subject.build(Buildable.new(foo: 1, bar: 2), 9) {|f| foo(f)}).to eql(
        Buildable.new(foo: 9, bar: 2)
      )
    end
  end

  describe '#inspect' do
    subject do
      Yaks::Builder.new(Buildable, [:foo, :bar])
    end

    it 'should show the class and methods' do
      expect(subject.inspect).to eql '#<Builder Buildable [:foo, :bar]>'
    end
  end

end
