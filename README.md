# Yaks Serializers

Turn your models into JSON or whatever. It is designed to support multiple formats, including non-json formats.

At the moment it supports

* [JSON-API](http://jsonapi.org), the [id style](http://jsonapi.org/format/#id-based-json-api)
* AMS compat, identical to ActiveModel::Serializers with `embed :ids, include: true`

Yaks is syntax compatible with a subset of ActiveModel::Serializers.

It does the serialization in two distinct phases. It first creates a (lazy) collection of the objects with their attributes and associations that need to be serialized, and in a second phase "folds" this into primitives (Hash, Array, String, Numeric, etc.) that can be passed to `JSON.dump` or similar.

The implementation follows the principle of separating policy from mechanism. For example, by default the serializer class is inferred from the model name in a certain way, but this is policy that can be easily changed.

For each object type you want to serialize, implement a serializer like so (demonstrating here with [Virtus](https://github.com/solnic/virtus) models)

```ruby
class Post
  include Virtus.model

  attribute :id, Integer
  attribute :title, String
  attribute :body, String
end

class PostSerializer < Yaks::Serializer
  attributes :id, :title, :body
end

JSON.dump(
  Yaks.dump('posts', [Post.new(id: 2, title: 'foo', body: 'bar')])
)
```

By default which serializer to use is inferred from the class name. To change that, pass in a `:serializer_lookup` object that responds to `call(object)` and returns the right serializer class.

By default objects are identified by their `:id`, to change that, configure an `identity_key`

```ruby
class PostSerializer < Yaks::Serializer
  attributes :href, :title, :body
  identity_key :href
end
```

Serialize associations by defining `has_one` and `has_many`

```ruby
class ShowSerializer < Yaks::Serializer
  attributes :id, :name, :description, :dates

  has_many :events
  has_one :event_category

  def description
    object.description(:long)
  end

  def dates
    events.map(&:day)
  end
end

class EventSerializer < Yaks::Serializer
  attributes :id, :name
end

class EventCategorySerializer < Yaks::Serializer
  attributes :id, :name
end

json = JSON.dump(
  Yaks::Dumper.new(format: :json_api).dump('shows', Show.upcoming)
)
```

## Non-Features

* No core extensions
* Minimal dependencies
* Only serializes what explicitly has a Serializer, will never call to_json/as_json
* Adding extra output formats does not require altering existing code
* Has no opinion on what to use for final JSON encoding (json, multi_json, yajl, oj, etc.)

## Formats

* :json_api

```json
{
   "shows" : [
      {
         "dates" : [ "next Sunday" ],
         "name" : "Piglet gets his groove back",
         "id" : 5,
         "description" : "Once in a lifetime...",
         "links" : {
            "event_category" : 2,
            "events" : [ 7 ]
         }
      }
   ],
   "linked" : {
      "event_categories" : [
         {
            "name" : "Drama",
            "id" : 2
         }
      ],
      "events" : [
         {
            "name" : "Sneak preview",
            "id" : 7
         }
      ]
   }
}
```

* :ams_compat

```json
{
   "shows" : [
      {
         "dates" : [ "next Sunday" ],
         "name" : "Piglet gets his groove back",
         "id" : 5,
         "description" : null,
         "event_ids" : [ 7 ],
         "event_category_id" : 2
      }
   ],
   "event_categories" : [{
         "name" : "Drama",
         "id" : 2
   }],
   "events" : [{
         "Name" : "Sneak preview",
         "id" : 7
   }]
}
```

## Maturity

Infantile. Crazy what these kids get up to.

requires current master of Hamster.

## License

MIT
