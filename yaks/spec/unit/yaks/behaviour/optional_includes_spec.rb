require "yaks/behaviour/optional_includes"

RSpec.describe Yaks::Behaviour::OptionalIncludes do
  include_context 'yaks context'

  subject(:mapper)   { mapper_class.new(yaks_context) }
  let(:resource)     { mapper.call(instance) }

  let(:mapper_class) do
    Class.new(Yaks::Mapper).tap do |mapper_class|
      mapper_class.send :include, Yaks::Behaviour::OptionalIncludes
      mapper_class.type "user"
      mapper_class.has_many :posts, mapper: post_mapper_class
      mapper_class.has_one :account, mapper: account_mapper_class
    end
  end
  let(:post_mapper_class) do
    Class.new(Yaks::Mapper).tap do |mapper_class|
      mapper_class.type "post"
      mapper_class.has_many :comments, mapper: comment_mapper_class
    end
  end
  let(:account_mapper_class) { Class.new(Yaks::Mapper) { type "account" } }
  let(:comment_mapper_class) { Class.new(Yaks::Mapper) { type "comment" } }

  let(:instance) { fake(posts: [fake(comments: [fake])], account: fake) }

  it "includes the associations" do
    rack_env["QUERY_STRING"] = "include=posts.comments,account"

    expect(resource.type).to eq "user"
    expect(resource.subresources[0].type).to eq "post"
    expect(resource.subresources[0].members[0].type).to eq "post"
    expect(resource.subresources[0].members[0].subresources[0].type).to eq "comment"
    expect(resource.subresources[0].members[0].subresources[0].members[0].type).to eq "comment"
    expect(resource.subresources[1].type).to eq "account"
  end

  it "excludes associations not specified in the QUERY_STRING" do
    rack_env["QUERY_STRING"] = "include=posts"

    expect(resource.subresources.count).to eq 1
  end

  it "doesn't include the associations when QUERY_STRING is empty" do
    expect(resource.type).to eq "user"
    expect(resource.subresources).to be_empty
  end

  it "allows :if to override the query parameter checking" do
    mapper_class.has_one :account, mapper: account_mapper_class, if: true

    expect(resource.subresources.count).to eq 1
  end

  it "caches parsing of the query parameter" do
    rack_env["QUERY_STRING"] = "include=posts"
    expect(mapper.call(instance).subresources.count).to eq 1

    rack_env["QUERY_STRING"] = nil
    expect(mapper.call(instance).subresources.count).to eq 1
  end
end
