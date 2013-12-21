require 'virtus'
require 'yaks'
require 'json'

Example = JSON.parse %q<
    {
      "posts": [{
        "id": "1",
        "title": "Rails is Omakase",
        "links": {
          "author": "9"
        }
      }],
      "linked": {
        "people": [{
          "id": "9",
          "name": "@d2h"
        }]
      }
    }
>


class Person
  include Virtus.model
  attribute :id, String
  attribute :name, String
end

class Post
  include Virtus.model
  attribute :id, String
  attribute :title, String
  attribute :author, Person
end

class PersonMapper < Yaks::Mapper
  attributes :id, :name
end

class PostMapper < Yaks::Mapper
  attributes :id, :title, :links

  has_one :author, mapper: PersonMapper
end

post = Post.new(
  id: 1,
  title: "Rails is Omakase",
  author: Person.new(id: "9", name: "@d2h"),
)

resource = PostMapper.new(post).to_resource

json_api = Yaks::JsonApiSerializer.new(resource, embed: :resources).to_json_api

gem 'minitest'
require 'minitest/autorun'

describe('json-api') {
  specify { assert_equal Example, json_api }
}
