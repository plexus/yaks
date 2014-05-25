require 'spec_helper'

describe Yaks::Resource do
  include_context 'shorthands'

  let(:object) { described_class.new(attributes, links, subresources) }
  let(:attributes) { {} }
  let(:links) { [] }
  let(:subresources) { {} }

end
