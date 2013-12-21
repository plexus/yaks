shared_context 'shorthands' do
  let(:resource) {
    ->(attrs, links = nil) {
      Yaks::Resource.new(Yaks::Hash(attrs), links, nil)
    }
  }

  let(:collection_resource) {
    ->(*attr_hashes) {
      Yaks::CollectionResource.new(
        nil,
        Yaks::List(attr_hashes.map(&resource.method(:call)))
      )
    }
  }

  let(:resource_link) {
    ->(rel, uri, options = {}) {
      Yaks::Resource::Link.new(rel, uri, options)
    }
  }
end
