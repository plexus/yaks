require 'spec_helper'

RSpec.describe 'assorted sanity checks' do
  let(:resource_methods)            { Yaks::Resource.public_instance_methods.sort }
  let(:collection_resource_methods) { Yaks::CollectionResource.public_instance_methods.sort }
  let(:null_resource_methods)       { Yaks::NullResource.public_instance_methods.sort }

  specify 'all resource classes should have the exact same public API' do
    expect(resource_methods).to eql null_resource_methods
    expect(resource_methods).to eql collection_resource_methods
  end
end
