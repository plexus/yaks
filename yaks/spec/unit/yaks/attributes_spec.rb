RSpec.describe Yaks::Attributes do
  subject { Class.new { include Yaks::Attributes.new(:foo, bar: 3) } }

  it 'should have a hash-based constructor' do
    expect(subject.new(foo: 3, bar: 4).bar).to equal 4
  end

  it 'should have defaults constructor' do
    expect(subject.new(foo: 3).bar).to equal 3
  end

  it 'should allow updating through with' do
    expect(subject.new(foo: 3).with(foo: 4).to_h).to eql(foo: 4, bar: 3)
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
    subject { Class.new(super()) { include attributes.add(baz: 7, bar: 4) } }

    it 'should make the new attributes available' do
      expect(subject.new(foo: 3, baz: 6).baz).to equal 6
    end

    it 'should make the old attributes available' do
      expect(subject.new(foo: 3, baz: 6).foo).to equal 3
    end

    it 'should take new default values' do
      expect(subject.new(foo: 3, baz: 6).bar).to equal 4
    end

    it 'should make sure attribute names are uniq' do
      expect(subject.attributes.names.length).to equal 3
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

  context 'when removing an attribute with a default' do
    subject { Class.new(super()) { include attributes.remove(:bar) } }

    it 'should still recognize attributes that were kept' do
      expect(subject.new(foo: 2).foo).to equal 2
    end

    it 'should no longer recognize the old attributes' do
      expect { subject.new(foo: 3, bar: 3).bar }.to raise_error
    end
  end

  context 'when removing an attribute without a default' do
    subject { Class.new(super()) { include attributes.remove(:foo) } }

    it 'should still recognize attributes that were kept' do
      expect(subject.new(bar: 2).bar).to equal 2
    end

    it 'should no longer recognize the old attributes' do
      expect { subject.new(foo: 3).foo }.to raise_error
    end

    it 'should keep the defaults' do
      expect(subject.new.bar).to equal 3
    end
  end
end

RSpec.describe Yaks::Attributes::InstanceMethods do
  let(:widget) do
    Class.new do
      include Yaks::Attributes.new(:color, :size, options: {})
      def self.name ; 'Widget' ; end
    end
  end

  let(:widget_container) do
    Class.new do
      include Yaks::Attributes.new(widgets: [])
      def self.name ; 'WidgetContainer' ; end
    end
  end

  let(:fixed_width) do
    Class.new do
      def initialize(width)
        @width = width
      end

      def inspect
        "#" * @width
      end
    end
  end

  describe '#pp' do
    it 'should render correctly' do
      expect(widget_container.new(widgets: [
                                    widget.new(color: :green, size: 7),
                                    widget.new(color: :blue, size: 9, options: {foo: :bar})
                                  ]).pp).to eql "
WidgetContainer.new(
  widgets: [
    Widget.new(color: :green, size: 7),
    Widget.new(color: :blue, size: 9, options: {:foo=>:bar})
  ]
)
".strip
    end

    it 'should inline short arrays' do
      expect(widget_container.new(widgets: [
                                    fixed_width.new(23),
                                    fixed_width.new(22)
                                  ]).pp).to eql "WidgetContainer.new(widgets: [#######################, ######################])"
    end

    it 'should put longer arrays on multiple lines' do
      expect(widget_container.new(widgets: [
                                    fixed_width.new(23),
                                    fixed_width.new(23)
                                  ]).pp).to eql "WidgetContainer.new(\n  widgets: [\n    #######################,\n    #######################\n  ]\n)"
    end

    it 'should puts attributes on multiple lines if total length exceeds 50 chars' do
      expect(widget.new(color: fixed_width.new(18), size: fixed_width.new(18)).pp).to match /\n/
      expect(widget.new(color: fixed_width.new(18), size: fixed_width.new(17)).pp).to_not match /\n/
    end
  end

  describe '#append_to' do
    it 'should append to a named collection' do
      expect(widget_container.new(widgets: [:bar]).append_to(:widgets, :foo)).to eql widget_container.new(widgets: [:bar, :foo])
    end
  end

  describe '#initialize' do
    it 'should take hash-based args' do
      expect(widget_container.new(widgets: [:bar])).to eql widget_container.new.with_widgets([:bar])
    end

    it 'should use defaults when available' do
      expect(widget.new(color: :blue, size: 3).options).to eql({})
    end
  end
end
