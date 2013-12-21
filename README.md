# Yaks

### One Stop Hypermedia Shopping ###

Yaks is a tool for turning your domain models into Hypermedia resources.

There are at the moment a number of competing media types for building Hypermedia APIs. These all add a layer of semantics on top of a low level serialization format such as JSON or XML. Even though they each have their own design goals, the core features mostly overlap. They typically provide a way to represent resources (entities), and resource collections, consisting of

* Data in key-value format, possibly with composite values
* Embedded resources
* Links to related resources
* Outbound links that have a specific relation to the resource

They might also contain extra control data to specify possible future interactions, not unlike HTML forms.

These different efforts to specify media types for Hypermedia clients and servers base themselves on the same set of internet standards, such as [RFC4288 Media types](http://tools.ietf.org/html/rfc4288), [RFC5988 Web Linking](http://tools.ietf.org/html/rfc5988), [RFC6906 The "profile" link relation](http://tools.ietf.org/search/rfc6906) and [RFC6570 URI Templates](http://tools.ietf.org/html/rfc6570).

## Yaks Resources

At the core of Yaks is the concept of a Resource, consisting of key-value attributes, RFC5988 style links, and embedded sub-resources. These standards are embraced as far as practically possible, for instance to find the URI that uniquely defines a resource, we look at the 'self' link. To distinguish different types of resources we use the 'profile' link.

## Mappers

To turn your domain models into resources, you define mappers, for example :

```ruby
class PostMapper < BaseMapper
  link :self, '/api/posts/{id}'

  attributes :id, :title

  has_one :author
  has_many :comments
end
```

Now you can use this to create a Resource

```ruby
resource = PostMapper.new(post).to_resource
```

## Serializers

A resource can be turned in to a specific media type representation, for example [HAL](http://stateless.co/hal_specification.html) using a Serializer

```ruby
hal = Yaks::HalSerializer.new(resource).serialize
puts JSON.dump(hal)
```

This will give you back a composite types consisting of primitives that have a mapping to JSON, so you can use your favorite JSON encoder to turn this into a character stream.

## Non-Features

* No core extensions
* Minimal dependencies
* Only serializes what explicitly has a Serializer, will never call to_json/as_json
* Adding extra output formats does not require altering existing code
* Has no opinion on what to use for final JSON encoding (json, multi_json, yajl, oj, etc.)


## License

MIT
