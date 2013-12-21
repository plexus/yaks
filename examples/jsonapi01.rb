# -*- coding: utf-8 -*-

# {
#   "posts": [{
#     "id": "1",
#     "title": "Rails is Omakase",
#     "links": {
#       "author": "9",
#       "comments": [ "5", "12", "17", "20" ]
#     }
#   }]
# }

require 'virtus'
require 'yaks'
require 'json'

class Author
  include Virtus.model
  attribute :id, String
end

class Comment
  include Virtus.model
  attribute :id, String
end

class Post
  include Virtus.model
  attribute :id, String
  attribute :title, String
  attribute :author, Author
  attribute :comments, Array[Comment]
end

class AuthorMapper < Yaks::Mapper
  attributes :id
end

class CommentMapper < Yaks::Mapper
  attributes :id
end

class PostMapper < Yaks::Mapper
  profile :post

  attributes :id, :title, :links

  has_one :author, mapper: AuthorMapper, embed: :ids
  has_many :comments, mapper: CommentMapper, embed: :ids
end

post = Post.new(
  id: 1,
  title: "Rails is Omakase",
  author: Author.new(id: "9"),
  comments: [5, 12, 17, 20].map {|id| Comment.new(id: id.to_s)}
)

resource = PostMapper.new(post).to_resource
json_api = Yaks::JsonApiSerializer.new(resource).to_json_api

gem 'minitest'
require 'minitest/autorun'

Example = JSON.parse(%q<{
  "posts": [{
    "id": "1",
    "title": "Rails is Omakase",
    "links": {
      "author": "9",
      "comments": [ "5", "12", "17", "20" ]
    }
  }]
}>
)

describe 'json-api' do
  specify do
    assert_equal Example, json_api
  end
end
