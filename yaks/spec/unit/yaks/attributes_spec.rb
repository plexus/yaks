require 'spec_helper'

RSpec.describe Yaks::Attributes do
  subject { Class.new { include Yaks::Attributes.new(:foo, bar: 3) } }

  it 'should have a hash-based constructor' do
    expect(subject.new(foo: 3, bar: 4).bar).to equal 4
  end

  it 'should have defaults constructor' do
    expect(subject.new(foo: 3).bar).to equal 3
  end

  it 'should allow updating through attribute methods' do
    expect(subject.new(foo: 3).foo(4).to_h).to eql(foo: 4, bar: 3)
  end

  it 'should add an #append_to method' do
    expect(subject.new(foo: [6]).append_to(:foo, 7, 8).foo).to eql [6, 7, 8]
  end

  context 'with all defaults' do
    subject { Class.new { include Yaks::Attributes.new(foo: 5, bar: 3) } }

    it 'should be able to construct without arguments' do
      expect(subject.new.to_h).to eql(foo: 5, bar: 3)
    end
  end

  context 'without any defaults' do
    subject { Class.new { include Yaks::Attributes.new(:foo, :bar) } }

    it 'should allow setting all attributes' do
      expect(subject.new(foo: 5, bar: 6).bar).to equal 6
    end

    it 'should expect all attributes' do
      expect { subject.new(foo: 5) }.to raise_exception
    end
  end

  context 'when extending' do
    subject { Class.new(super()) { include attributes.add(baz: 7) } }

    it 'should make the new attributes available' do
      expect(subject.new(foo: 3, baz: 6).baz).to equal 6
    end

    it 'should make the old attributes available' do
      expect(subject.new(foo: 3, baz: 6).foo).to equal 3
    end

    context 'without any defaults' do
      subject { Class.new(super()) { include attributes.add(:bax) } }

      it 'should allow setting all attributes' do
        expect(subject.new(foo: 5, bar: 6, bax: 7).bax).to equal 7
      end

      it 'should expect all attributes' do
        expect { subject.new(foo: 5, bar: 6) }.to raise_exception
      end
    end
  end
end
