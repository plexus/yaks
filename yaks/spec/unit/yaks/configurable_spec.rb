class Kitten
  include Yaks::Attributes.new(:furriness)

  def self.create(opts, &block)
    level = opts[:fur_level]
    level = block.call(level) if block
    new(furriness: level)
  end
end

class Hanky
  include Yaks::Attributes.new(:stickyness, :size, :color)

  def self.create(sticky, opts = {})
    new(stickyness: sticky, size: opts[:size], color: opts[:color])
  end
end

RSpec.describe Yaks::Configurable do
  let(:suffix) { SecureRandom.hex(16) }
  subject do
    eval %Q<
class TestConfigurable#{suffix}
  class Config
    include Yaks::Attributes.new(color: 'blue', taste: 'sour', contents: [])
  end
  extend Yaks::Configurable

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
    end
  end
  describe '#def_forward' do
    it 'should forward' do
    end
  end
end
