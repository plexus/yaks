require 'spec_helper'

describe Yaks::Mapper::HasOne do
  include_context 'shorthands'

  AuthorMapper = Class.new(Yaks::Mapper) { attributes :name }

  let(:name)     { 'William S. Burroughs' }
  let(:mapper)   { AuthorMapper }
  let(:has_one)  { described_class.new(:author, :author, mapper, [], {}) }
  let(:author)   { Struct.new(:name).new(name) }

  it 'should map to a single Resource' do
    expect(has_one.map_resource(author)).to eq resource[{name: name}, [resource_link[:profile, 'author']]]
  end
end
