[![Gem Version](https://badge.fury.io/rb/yaks.png)][gem]
[![Build Status](https://secure.travis-ci.org/plexus/yaks.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/plexus/yaks.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/plexus/yaks.png)][codeclimate]

[gem]: https://rubygems.org/gems/yaks
[travis]: https://travis-ci.org/plexus/yaks
[gemnasium]: https://gemnasium.com/plexus/yaks
[codeclimate]: https://codeclimate.com/github/plexus/yaks

# Yaks

### One Stop Hypermedia Shopping ###

Yaks is a tool for turning your domain models into Hypermedia resources.

There are at the moment a number of competing media types for building Hypermedia APIs. These all add a layer of semantics on top of a low level serialization format such as JSON or XML. Even though they each have their own design goals, the core features mostly overlap. They typically provide a way to represent resources (entities), and resource collections, consisting of

* Data in key-value format, possibly with composite values
* Embedded resources
* Links to related resources
* Outbound links that have a specific relation to the resource

They might also contain extra control data to specify possible future interactions, not unlike HTML forms.

These different media types for Hypermedia clients and servers base themselves on the same set of internet standards, such as [RFC4288 Media types](http://tools.ietf.org/html/rfc4288), [RFC5988 Web Linking](http://tools.ietf.org/html/rfc5988), [RFC6906 The "profile" link relation](http://tools.ietf.org/search/rfc6906) and [RFC6570 URI Templates](http://tools.ietf.org/html/rfc6570).

## Yaks Resources

At the core of Yaks is the concept of a Resource, consisting of key-value attributes, RFC5988 style links, and embedded sub-resources.

To build an API you create 'mappers' that turn your domain models into resources. Then you pick a media type 'serializer', which can turn the resource into a hypermedia message.

The web linking standard which defines link relations like 'self', 'next' or 'alternate' is embraced as far as practically possible, for instance to find the URI that uniquely defines a resource, we look at the 'self' link. To distinguish different types of resources we use the 'profile' link.

## Mappers

To turn your domain models into resources, you define mappers, for example :

```ruby
class PostMapper < Yaks::Mapper
  link :self, '/api/posts/{id}'

  attributes :id, :title

  has_one :author
  has_many :comments
end
```

Configure a Yaks instance and start serializing!

```ruby
yaks = Yaks.new
yaks.serialize(post)
```

or a bit more elaborate

```ruby
yaks = Yaks.new do
  default_format :json_api
  rel_template 'http://api.example.com/rels/{association_name}'
  format_options(:hal, plural_links: [:copyright])
end

yaks.serialize(post, mapper: PostMapper, format: :hal)
```

Yaks by default will find your mappers for you if they follow the naming convention of appending 'Mapper' to the model class name. This (and all other "conventions") can be easily redefined though, see below. If you have your mappers inside a module, use `mapper_namespace`.

```ruby
module API
  module Mappers
    class PostMapper < Yaks::Mapper
      #...
    end
  end
end

yaks = Yaks.new do
  mapper_namespace API::Mappers
end
```

### Attributes

Use the `attributes` DSL method to specify which attributes of your model you want to expose, as in the example above. You can override the `load_attribute` method to change how attributes are fetched from the model.

For example, if you are representing data that is stored in a Hash, you could do

```ruby
class PostHashMapper < Yaks::Mapper
  attributes :id, :body

  # @param name [Symbol]
  def load_attribute(name)
    object[name]
  end
end
```

The default implementation will first try to find a matching method for an attribute on the mapper itself, and will then fall back to calling the actual model. So you can add extra 'virtual' attributes like so :

```ruby
class CommentMapper < Yaks::Mapper
  attributes :id, :body, :date

  def date
    object.created_at.strftime("at %I:%M%p")
  end
end
```

#### Filtering

Implement `filter(attrs)` to filter out specific attributes, e.g. based on options.

```ruby
def filter(attrs)
  attrs.reject{|attr| options[:exclude].include? attr
end
```

### Links

You can specify link templates that will be expanded with model attributes. The link relation name should be a registered [IANA link relation](http://www.iana.org/assignments/link-relations/link-relations.xhtml) or a URL. The template syntax follows [RFC6570 URI templates](http://tools.ietf.org/html/rfc6570).

```ruby
class FooMapper < Yaks::Mapper
  link :self, '/api/foo/{id}'
  link 'http://api.foo.com/rels/comments', '/api/foo/{id}/comments'
end
```

To prevent a link to be expanded, add `expand: false` as an option. Now the actual template will be rendered in the result, so clients can use it to generate links from.

To partially expand the template, pass an array with field names to expand. e.g.

```ruby
class ProductMapper < Yaks::Mapper
  link 'http://api.foo.com/rels/line_item', '/api/line_items?product_id={product_id}&quantity={quantity}', expand: [:product_id]
end

# "_links": {
#    "http://api.foo.com/rels/line_item": {
#      "href": "/api/line_items?product_id=273&quantity={quantity}",
#      "templated": true
#    }
# }

```

You can pass a symbol instead of a template, in that case the symbol will be used as a method name on the object to retrieve the link. You can override this behavior just like with attributes.

```ruby
class FooMapper < Yaks::Mapper
  link 'http://api.foo.com/rels/go_home', :home_url
  # by default calls object.home_url

  def home_url
    object.setting('home_url')
  end
end
```

### Associations

Use `has_one` for an association that returns a single object, or `has_many` for embedding a collection.

Options

* `:as` : use a different name for the association in the result
* `:mapper` : Use a specific for each instance, will be derived from the class name if omitted (see Policy vs Configuration)
* `:collection_mapper` : For mapping the collection as a whole, this defaults to Yaks::CollectionMapper, but you can subclass it for example to add links or attributes on the collection itself
* `:policy` : supply an alternative Policy object

## Resources and Serializers

Yaks uses an intermediate "Resource" representation to support multiple output formats. A mapper turns a domain model into a `Yaks::Resource`. A serializer (e.g. `Yaks::HalSerializer`) takes the resource and outputs the structure of the target format.

Since version 0.4 the recommended API is through `Yaks.new {...}.serialize`. This will give you back a composite types consisting of primitives that have a mapping to JSON, so you can use your favorite JSON encoder to turn this into a character stream.

```ruby
my_yaks = Yaks.new
hal = my_yaks.serialize(model)
puts JSON.dump(hal)
```

There are at least a handful of JSON libraries and implementations for Ruby out there, with different trade-offs. Yaks does not impose an opinion on which one to use

### Yaks::HalSerializer

Serializes to HAL, this is chose by default. In HAL one decides when building an API which links can only be singular (e.g. self), and which are always represented as an array. Yaks defaults to singular as I've found it to be the most common case. If you want specific links to be plural, then configure their rel href as such.

```ruby
hal = Yaks.new do
  format_options hal, plural_links: ['http://api.example.com/rels/foo']
end
```

CURIEs are not explicitly supported (yet), but it's possible to use them with some effort, see `examples/hal01.rb` for an example.

The line between a singular resource and a collection is fuzzy in HAL. To stick close to the spec you're best to create your own singular types that represent collections, rather than rendering a top level CollectionResource.

### Yaks::JsonApiSerializer

JSON-API has no concept of outbound links, so these will not be rendered. Instead the key will be inferred from the mapper class name by default. This can be changed per mapper:

```ruby
class AnimalMapper
  key :pet
end
```

Or the policy can be overridden:

```ruby
yaks = Yaks.new do
  derive_type_from_mapper_class do |mapper_class|
    piglatinize(mapper_class.to_s.sub(/Mapper$/, ''))
  end
end
```

## Policy over Configuration

It's an old adage in the Ruby/Rails world to have "Convention over Configuration", mostly to derive values that were not given explicitly. Typically based on things having similar names and a 1-1 derivable relationship.

This saves a lot of typing, but for the uninitiated it can also create confusion, the implicitness makes it hard to follow what's going on.

What's worse, is that often the Configuration part is skimmed over, making it very hard to deviate from the Golden Standard.

There is another old adage, "Policy vs Mechanism". Implement the mechanisms, but don't dictate the policy.

In Yaks whenever missing values need to be inferred, like finding an unspecified mapper for a relation, this is handled by a policy object. The default is `Yaks::DefaultPolicy`, you can go there to find all the rules of inference. Single rules of inference can be redefined directly in the Yaks configuration:

```ruby
yaks = Yaks.new do
  derive_mapper_from_model do |model|
    # ...
  end

  derive_type_from_mapper_class do |mapper_class|
    # ...
  end

  derive_mapper_from_association do |association|
    # ...
  end

  derive_rel_from_association do |mapper, association|
    # ...
  end
end
```

You can also subclass or create from scratch your own policy class

```ruby
class MyPolicy < DefaultPolicy
  #...
end

yaks = Yaks.new do
  policy MyPolicy
end
```

## Usage

Yaks is used in production by [Ticketsolve](http://www.ticketsolve.com/). You can find an example API endpoint [here](http://leicestersquaretheatre.ticketsolve.com/api).

Get in touch if you like to see your name and API here.

## Acknowledgment

The mapper syntax is largely borrowed from ActiveModel::Serializers, which in turn closely mimics the syntax of ActiveRecord models. It's a great concise syntax that still offers plenty of flexibility, so to not reinvent the wheel I've stuck to the existing syntax as far as practical, although there are several extensions and deviations.

## How to contribute

Run the tests, the examples, try it with your own stuff and leave your impressions in the issues. Or discuss on API-craft.

To fix a bug

1. Fork the repo
2. Fix the bug, add tests for it
3. Push it to a named branch
4. Add a PR

To add a feature

1. Open an issue as soon as possible to gather feedback
2. Same as above, fork, push to named branch, make a pull-request

## Lightweight

Yaks is a lean library. It only depends on a few other tiny libraries (inflection, concord, uri_template). It has no core extensions (monkey patches). There is deliberately no built-in "integration" with existing frameworks, since the API is simply enough. You just call it.

If this approach sounds appealing, have a look at [microrb.com](http://microrb.com/).

## License

MIT
