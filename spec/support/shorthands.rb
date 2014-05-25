shared_context 'shorthands' do
  let(:resource) {
    ->(attrs, links = nil) {
      Yaks::Resource.new(attrs, links, nil)
    }
  }

  let(:collection_resource) {
    ->(*attr_hashes) {
      Yaks::CollectionResource.new(
        nil,
        attr_hashes.map(&resource.method(:call))
      )
    }
  }

  let(:resource_link) {
    ->(rel, uri, options = {}) {
      Yaks::Resource::Link.new(rel, uri, options)
    }
  }
end
