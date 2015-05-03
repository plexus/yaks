class Kitten
  include Attribs.new(:furriness)

  def self.create(opts, &block)
    level = opts[:fur_level]
    level = block.call(level) if block
    new(furriness: level)
  end
end

class Hanky
  include Attribs.new(:stickyness, :size, :color)

  def self.create(sticky, opts = {})
    new(stickyness: sticky, size: opts[:size], color: opts[:color])
  end
end

RSpec.describe Yaks::Configurable do
  let(:suffix) { SecureRandom.hex(16) }
  subject do
    eval %<
class TestConfigurable#{suffix}
  class Config
    include Attribs.new(color: 'blue', taste: 'sour', contents: [])

    def turn_into_orange
      with(color: 'orange', taste: 'like an orange')
    end

    def turn_into_apple
      with(color: 'green', taste: 'like an apple')
    end

    def with_color_and_contents(color)
      with(color: color, contents: yield(contents))
    end
  end
  extend Yaks::Configurable

  def_set :color, :taste
  def_forward :turn_into_apple, :turn_into_orange, :with_color_and_contents
  def_forward appleize: :turn_into_apple
  def_add :kitten, create: Kitten, append_to: :contents, defaults: {fur_level: 7}
  def_add :cat, create: Kitten, append_to: :contents
  def_add :hanky, create: Hanky, append_to: :contents, defaults: {size: 12, color: :red}
end
>
    Kernel.const_get("TestConfigurable#{suffix}")
  end

  describe '.extended' do
    it 'should initialize an empty config object' do
      expect(subject.config).to eql subject::Config.new
    end
  end

  describe '#def_add' do
    it 'should add' do
      subject.kitten(fur_level: 9)
      expect(subject.config.contents).to eql [Kitten.new(furriness: 9)]
    end

    it 'should use defaults if configured' do
      subject.kitten
      expect(subject.config.contents).to eql [Kitten.new(furriness: 7)]
    end

    it 'should work without defaults configured' do
      subject.cat(fur_level: 3)
      expect(subject.config.contents).to eql [Kitten.new(furriness: 3)]
    end

    it 'should pass on a block' do
      subject.cat(fur_level: 3) {|l| l+3}
      expect(subject.config.contents).to eql [Kitten.new(furriness: 6)]
    end

    it 'should work with a create with positional arguments - defaults' do
      subject.hanky(3)
      expect(subject.config.contents).to eql [Hanky.new(stickyness: 3, size: 12, color: :red)]
    end

    it 'should work with a create with positional arguments' do
      subject.hanky(5, size: 15)
      expect(subject.config.contents).to eql [Hanky.new(stickyness: 5, size: 15, color: :red)]
    end
  end

  describe '#def_set' do
    it 'should set' do
      subject.color 'red'
      expect(subject.config.color).to eql 'red'
    end

    it 'should capture blocks as closures' do
      subject.color {|x| "#{x} blue"}
      expect(subject.config.color.call("dark")).to eql 'dark blue'
    end

    it 'should signal when called without arguments' do
      expect { subject.color }.to raise_error(ArgumentError, "setting color: no value and no block given")
    end

    it 'is an error when both a value and a block are passed in' do
      expect { subject.color('red') {'blue'} }.to raise_error(ArgumentError, "ambiguous invocation setting color: give either a value or a block, not both.")
    end
  end

  describe '#def_forward' do
    it 'should generate a method that delegates to the config instance - first position' do
      subject.turn_into_orange
      expect(subject.config.color).to eql 'orange'
    end

    it 'should generate a method that delegates to the config instance - last position' do
      subject.turn_into_apple
      expect(subject.config.color).to eql 'green'
    end

    it 'should work with a hash for mappings' do
      subject.appleize
      expect(subject.config.color).to eql 'green'
    end

    it 'should forward arguments and block' do
      subject.with_color_and_contents('brown') do |contents|
        contents + [1, 2, 3]
      end

      expect(subject.config.color).to eql 'brown'
      expect(subject.config.contents).to eql [1, 2, 3]
    end
  end

  describe '#inherited' do
    it 'should propagate the config state' do
      subject.appleize
      expect(Class.new(subject).config.color).to eql 'green'
    end
  end
end
