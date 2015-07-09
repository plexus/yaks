[![Gem Version](https://badge.fury.io/rb/yaks.png)][gem]
[![Build Status](https://secure.travis-ci.org/plexus/yaks.png?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/plexus/yaks.png)][codeclimate]
[![Gitter](https://badges.gitter.im/Join Chat.svg)][gitter]

[gem]: https://rubygems.org/gems/yaks
[travis]: https://travis-ci.org/plexus/yaks
[codeclimate]: https://codeclimate.com/github/plexus/yaks
[gitter]: https://gitter.im/plexus/yaks?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge

# Yaks

<img align="left" src="https://raw.githubusercontent.com/plexus/yaks/master/logo.png">

The library that understands hypermedia.

**If you use Yaks please help out by filling out the [Yaks Users Survey](https://docs.google.com/forms/d/1sZB03Vf32igmNmJ7RP8mo8H4VZHcVIpSrUSbvx2xD8s/viewform)**

Yaks takes your data and transforms it into hypermedia formats such as
HAL, JSON-API, or HTML. It allows you to build APIs that are
discoverable and browsable. It is built from the ground up around
linked resources, a concept central to the architecture of the web.

Yaks consists of a resource representation that is independent of any
output type. A Yaks mapper transforms an object into a resource, which
can then be serialized into whichever output format the client
requested. These formats are presently supported:

* HAL
* JSON API
* Collection+JSON
* HTML
* HALO
* Transit

## Table of Contents

- [State of Development](#user-content-state-of-development)
- [Concepts](#user-content-concepts)
- [Mappers](#user-content-mappers)
  - [Attributes](#user-content-attributes)
  - [Forms](#user-content-forms)
    - [Filtering](#user-content-filtering)
  - [Links](#user-content-links)
  - [Associations](#user-content-associations)
- [Calling Yaks](#user-content-calling-yaks)
  - [Rack env](#user-content-rack-env)
- [Namespace](#user-content-namespace)
- [Custom attribute/link/subresource handling](#user-content-custom-attributelinksubresource-handling)
- [Resources, Formatters, Serializers](#user-content-resources-formatters-serializers)
- [Formats](#user-content-formats)
  - [HAL](#user-content-hal)
  - [HTML](#user-content-html)
  - [JSON-API](#user-content-json-api)
  - [Collection+JSON](#user-content-collection-json)
  - [Transit](#user-content-transit)
- [Hooks](#user-content-hooks)
- [Policy over Configuration](#user-content-policy-over-configuration)
  - [derive_mapper_from_object](#user-content-derive_mapper_from_object)
  - [derive_mapper_from_association](#user-content-derive_mapper_from_association)
  - [derive_rel_from_association](#user-content-derive_rel_from_association)
- [Primitivizer](#user-content-primitivizer)
- [Integration](#user-content-integration)
- [Real World Usage](#user-content-real-world-usage)
- [Demo](#user-content-demo)
- [Cookbook](#user-content-cookbook)
- [Standards Based](#user-content-standards-based)
- [How to contribute](#user-content-how-to-contribute)
- [License](#user-content-license)

## Packages

- [yaks-sinatra](yaks-sinatra/README.md)
- [yaks-html](yaks-html/README.md)
- [yaks-transit](yaks-transit/README.md)

## State of Development

Recent focus has been on stabilizing the core classes, improving
format support, and increasing test (mutation) coverage. We are
committed to a stable public API and semantic version. On the 0.x line
the minor version is bumped when non-backwards compatible changes are
introduced. After 1.x regular semver conventions will be used.

## Concepts

Yaks is a processing pipeline, you create and configure the pipeline,
then feed data through it.

``` ruby
yaks = Yaks.new do
  default_format :hal
  rel_template 'http://api.example.com/rels/{rel}'
  format_options(:hal, plural_links: [:copyright])
  mapper_namespace ::MyAPI
  json_serializer do |data|
    JSON.dump(data)
  end
end

yaks.call(product)
```

Yaks performs this serialization in three steps

* It *maps* your data to a `Yaks::Resource`
* It *formats* the resource to a syntax tree representation
* It *serializes* to get the final output

For JSON types, the "syntax tree" is just a combination of Ruby primitives, nested arrays and hashes with strings, numbers, booleans, nils.

A Resource is an abstraction shared by all output formats. It can contain key-value attributes, RFC5988 style links, and embedded sub-resources.

To build an API you create a "mapper" for each type of object you want to represent. Yaks takes care of the rest.

For all configuration options see [Yaks::Config::DSL](http://rdoc.info/gems/yaks/frames/Yaks/Config/DSL).

See also the [API Docs on rdoc.info](http://rdoc.info/gems/yaks/frames/file/README.md)

## Mappers

Say your app has a `Post` object for blog posts. To serve posts over your API, define a `PostMapper`

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
yaks.call(post)
```

or a bit more elaborate

```ruby
yaks = Yaks.new do
  default_format :json_api
  rel_template 'http://api.example.com/rels/{rel}'
  format_options(:hal, plural_links: [:copyright])
end

yaks.call(post, mapper: ::PostMapper, format: :hal)
```

### Attributes

Use the `attribute` or `attributes` DSL methods to specify which attributes of your model you want to expose, as in the example above. You can override the `load_attribute` method to change how attributes are fetched from the model.

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
The `attribute` method may also take a block that will be called with the context of the mapper instance. The default implementation will use the block if provided, otherwise it will first try to find a matching method for an attribute on the mapper itself, and will then fall back to calling the actual model. So you can add extra 'virtual' attributes like so :

```ruby
class CommentMapper < Yaks::Mapper
  attributes :body, :date
  attribute :id do
    "Id-#{object.id}"
  end

  def date
    object.created_at.strftime("at %I:%M%p")
  end
end
```

### Forms

Mapper can contain form defintions, for formats that support them. The
form DSL mimics the HTML5 field and attribute names.

```ruby
class PostMapper < Yaks::Mapper
  attributes :id, :body, :date

  form :add_comment do
    action '/api/comments'
    method 'POST'
    media_type 'application/json'

    text :body
    hidden :post_id, value: -> { object.id }
  end
end
```

TODO: add more info on form element types, attributes, conditional
rendering of forms, dynamic form sections, ...


#### Filtering

You can override `#attributes`, or `#associations`.

```ruby
class SongMapper < Yaks::Mapper
  attributes :title, :duration, :lyrics

  has_one :artist
  has_one :album

  def minimal?
    env['HTTP_PREFER'] =~ /minimal/
  end

  # @return Array<Yaks::Mapper::Attribute>
  def attributes
    return super.reject {|attr| attr.name.equal? :lyrics } if minimal?
    super
  end

  # @return Array<Yaks::Mapper::Association>
  def associations
    return [] if minimal?
    super
  end
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

You can pass a proc instead of a template, in that case the proc will
be resolved in the context of the mapper. What this means is that, if
the proc takes no arguments, it will be evaluated with the mapper
instance as the value of `self`. If the proc does take an argument,
then it will receive the mapper instance, and will be evaluated as a
closure, i.e. with access to the scope in which it was defined.

```ruby
class FooMapper < Yaks::Mapper
  link 'http://api.foo.com/rels/go_home', -> { home_url }
  # by default calls object.home_url

  def home_url
    object.setting('home_url')
  end
end
```


To only include links based on certain conditions, add an `:if`
option, passing it a block. The block will be resolved in the context
of the mapper, as explained before.

For example, say you want to notify the consumer of your API that upon
confirming an order, the previously held cart is no longer valid, you
could use the IANA standard `invalidates` rel to communicate this.

``` ruby
class OrderMapper < Yaks::Mapper
  link :invalidates, '/api/cart', if: ->{ env['api.invalidate_cart'] }
end
```

### Associations

Use `has_one` for an association that returns a single object, or `has_many` for embedding a collection.

Options

* `:mapper` : Use a specific for each instance, will be derived from the class name if omitted (see Policy vs Configuration)
* `:collection_mapper` : For mapping the collection as a whole, this defaults to Yaks::CollectionMapper, but you can subclass it for example to add links or attributes on the collection itself
* `:rel` : Set the relation (symbol or URI) this association has with the object. Will be derived from the association name and the configured rel_template if ommitted
* `:if`: Only render the association if a condition holds
* `:link_if`: Conditionally render the association as a link. A `:href` option is required

```ruby
class ShowMapper < Yaks::Mapper
  has_many :events, href: '/show/{id}/events', link_if: ->{ events.count > 50 }
end
```

## Calling Yaks

Once you have a Yaks instance, you can call it with `call`
(`serialize` also works but might be deprecated in the future.) Pass
it the data to be serialized, plus options.

* `:env` a Rack environment, see next section
* `:format` the format to be used, e.g. `:json_api`. Note that if the Rack env contains an `Accept` header which resolves to a recognized format, then the header takes precedence
* `:mapper` the mapper to be used. Will be inferred if omitted
* `:item_mapper` When rendering a collection, the mapper to be used for each item in the collection. Will be inferred from the class of the first item in the collection if omitted.

### Rack env

When serializing, Yaks lets you pass in an `env` hash, which will be made available to all mappers.

```ruby
class FooMapper < Yaks::Mapper
  attributes :bar

  def bar
    if env['something']
      #...
    end
  end
end

yaks = Yaks.new
yaks.call(foo, env: my_env)
```

The env hash will be available to all mappers, so you can use this to
pass around context. In particular context related to the current HTTP
request, e.g. the current logged in user, which is why the recommended
use is to pass in the Rack environment.

If `env` contains a `HTTP_ACCEPT` key (Rack's way of representing the
`Accept` header), Yaks will return the format that most closely
matches what was requested.

<a id="namespace"></a>

## Namespace

Yaks by default will find your mappers for you if they follow the
naming convention of appending 'Mapper' to the model class name. This
(and all other "conventions") can be easily redefined though, see the
<a href="#policy">policy</a> section. If you have your mappers inside a
module, use `mapper_namespace`.

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

If your namespace contains a `CollectionMapper`, Yaks will use that
instead of `Yaks::CollectionMapper`, e.g.

```ruby
module API
  module Mappers
    class CollectionMapper < Yaks::CollectionMapper
      link :profile, 'http://api.example.com/profiles/collection'
    end
  end
end
```

You can also have collection mappers based on the type of members the
collection holds, e.g.

```ruby
module API
  module Mappers
    class LineItemCollectionMapper < Yaks::CollectionMapper
      link :profile, 'http://api.example.com/profiles/line_items'
      attributes :total

      def total
        collection.inject(0) do |memo, line_item|
          memo + line_item.price * line_item.quantity
        end
      end
    end
  end
end
```

Yaks will automatically detect and use this collection when
serializing an array of `LineItem` objects. See <a
href="#derive_mapper_from_object">derive_mapper_from_object</a> for
details.


## Custom attribute/link/subresource handling

When inheriting from `Yaks::Mapper`, you can override
`map_attributes`, `map_links` and `map_resources` to skip (or augment)
above methods, and instead implement your own custom mechanism. These
methods take a `Yaks::Resource` instance, and should return an updated
resource. They should not alter the resource instance in-place. For
example

```ruby
class ErrorMapper < Yaks::Mapper
  link :profile, '/api/error'

  def map_attributes(resource)
    attrs = {
      http_code: 500,
      message: object.to_s,
      type: object.class.name.underscore
    }

    case object
    when AllocationException
      attrs[:http_code] = 422
    when ActiveRecord::RecordNotFound
      attrs[:http_code] = 404
      attrs[:type] = "record_not_found"
    end

    resource.update_attributes(attrs)
  end
end
```

## Resources, Formatters, Serializers

Yaks uses an intermediate "Resource" representation to support
multiple output formats. A mapper turns a domain model into a
`Yaks::Resource`. A formatter (e.g. `Yaks::Format::Hal`) takes
the resource and outputs the structure of the target format.

Finally a serializer will take this document structure and turn it
into a string. For JSON documents the intermediate format consists of
Ruby primitives like arrays and hashes. HTML/XML based formats on the
other hand return a [Hexp::Node](https://github.com/plexus/hexp).

For JSON based format there's an extra step between `format` and
`serialize` called `primitivize`, this way Ruby objects which don't
have an equivalent in the JSON spec, like `Symbol` or `Date`, can be
turned into objects that are representable in JSON. See
[Primitiver](#primitivizer).

## Formats

Below follows a brief overview of formats that are available in
Yaks. The maturity of these formats varies, since we depend on people
that use a certain format actively to contribute. Implementing formats
is in generally straightforward, and consists mostly of deciding how
the attributes, links, forms, of a `Yaks::Resource` should be
represented. Depending on the format this might be a subject for
debate. We welcome these discussions, and if your opinion differs from
what ends up in Yaks, it should be trivial to change these
representations for your use case.

### HAL

This is the default. In HAL one decides when building an API which
links can only be singular (e.g. self), and which are always
represented as an array. Yaks defaults to singular as I've found it to
be the most common case. If you want specific links to be plural, then
configure their rel href as such.

```ruby
hal = Yaks.new do
  format_options :hal, plural_links: ['http://api.example.com/rels/foo']
end
```

CURIEs are not explicitly supported (yet), but it's possible to use
them with some manual effort.

The line between a singular resource and a collection is fuzzy in
HAL. To stick close to the spec you're best to create your own
singular types that represent collections, rather than rendering a top
level CollectionResource.

Yaks also has a derived format called HALO, which is a non-standard
extension to HAL which includes form elements.

### HTML

The hypermedia format *par excellence*. Yaks can generate a version of
your API, including links and forms, that is usable straight from a
standard web browser. This allows API interactions to be developed and
tested independent from any client application.

If you let Yaks handle your content type negotiation (i.e. pass it the
rack env, and honour the content type it detects, see
[integration](#integration), simply opening a browser and pointing it
at your API entry point should do the trick.

### JSON-API

The JSON-API spec has evolved since the Yaks formatter was
implemented. It is also not the most suitable format for Yaks
feature-set due to its strong convention-driven nature and weak
support for hypermedia.

At this time, The JSON-API specification has not reached a 1.0 release.
Some changes to the Yaks JSON-API formatter may still be required
before it is completely compatible with the latest version of the
specification.

If you would like to see better JSON-API support, get in touch. We
might be able to work something out.

```ruby
Yaks.new do
  default_format :json_api
end
```

JSON-API has no concept of outbound links, so these will not be
rendered. Instead the key will be inferred from the mapper class name
by default. This can be changed per mapper:

```ruby
class AnimalMapper < Yaks::Mapper
  type :pet
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

Yaks also has support for respecting the `include` query parameter (e.g.
`include=author,comments`), which is a behaviour you can include in
your mappers:

```ruby
require "yaks/behaviour/optional_includes"

class PostMapper < Yaks::Mapper
  include Yaks::Behaviour::OptionalIncludes

  has_one :author
  has_many :comments
end

# ...

yaks = Yaks.new
yaks.call(post, env: rack_env)
```

Now all your associations will be included only if specified in the `include`
query. Note that you need to pass the Rack env to Yaks, and that you need to
explicitly require `yaks/behaviour/optional_includes`. If you want some
associations to always be included regardless of the `include` query parameter,
just specify `:if` that returns true:

```ruby
require "yaks/behaviour/optional_includes"

class PostMapper < Yaks::Mapper
  include Yaks::Behaviour::OptionalIncludes

  has_one :author
  has_many :comments, if: ->{ true }
end
```

### Collection+JSON

Collection+JSON has support for write templates. To use them, the `:template`
option can be used. It will map the specified form to a CJ template. Please
notice that CJ only allows one template per representation.

```ruby
Yaks.new do
  default_format :collection_json

  collection_json = Yaks.new do
    format_options :collection_json, template: :my_template_form
  end
end

class PostMapper < Yaks::Mapper
  form :my_template_form do
    # This will be used for template
  end

  form :not_my_template do
    # This won't be used for template
  end
end
```

Subresources aren't mapped because Collection+JSON doesn't really have
that concept.

### Transit

There is experimental support for Transit. The transit gem handles
serialization internally, so there is no intermediate document. The
`format` step already returns the serialized string.

## Hooks

It is possible to hook into the Yaks pipeline to perform extra
processing steps before, after, or around each step. It also possible
to skip a step.

``` ruby
yaks = Yaks.new do
  # Automatically give every resource a self link
  after :map, :add_self_link do |resource|
    resource.add_link(Yaks::Resource::Link.new(:self, "/#{resource.type}/#{resource.attributes[:id]}"))
  end

  # Skip serialization, so Ruby primitives come back instead of JSON
  # This was the default before versions < 0.5.0
  skip :serialize
end
```

<a id="policy"></a>

## Policy over Configuration

It's an old adage in the Ruby/Rails world to have "Convention over Configuration", mostly to derive values that were not given explicitly. Typically based on things having similar names and a 1-1 derivable relationship.

This saves a lot of typing, but for the uninitiated it can also create confusion, the implicitness makes it hard to follow what's going on.

What's worse, is that often the Configuration part is skipped entirely, making it very hard to deviate from the Golden Standard.

There is another old adage, "Policy vs Mechanism". Implement the mechanisms, but don't dictate the policy.

In Yaks whenever missing values need to be inferred, like finding an unspecified mapper for a relation, this is handled by a policy object. The default is `Yaks::DefaultPolicy`, you can go there to find all the rules of inference. Single rules of inference can be redefined directly in the Yaks configuration:

```ruby
yaks = Yaks.new do
  mapper_for Post, SpecialMapper

  derive_mapper_from_object do |model|
    # ...
  end

  derive_mapper_from_collection do |collection|
    # ...
  end

  derive_mapper_from_item do |model|
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

Note that within these blocks, you may call `super()` which would call
the default implementation.

You can also subclass or create from scratch your own policy class

```ruby
class MyPolicy < Yaks::DefaultPolicy
  #...
end

yaks = Yaks.new do
  policy_class MyPolicy
end
```

<a id="derive_mapper_from_object"></a>

### derive_mapper_from_object

This is called when trying to serialize something and no explicit
mapper is given. To recap, it's always possible to be explicit, e.g.

```
yaks.call(widget, mapper: WidgetMapper)
yaks.call(array_of_widgets, mapper: MyCollectionMapper, item_mapper: WidgetMapper)
```

If the mapper is left unspecified, Yaks will inspect whatever you pass
it. First it will test the given object against the mappings defined using `mapper_for`.
If no mapper is found, it will call `derive_mapper_from_item` or `derive_mapper_from_collection`
depending on whether the given object is a collection or not. If the object responds
to `to_ary` it is considered a collection.

### mapper_for

This method allows you to define a one-to-one mapping between a mapping rule and a mapper class.
During the lookup, Yaks will check if any mapping rule matches the given object using the `#===`
operator.

Here are a few examples on how to use it:
```ruby
yaks = Yaks.new do
  mapper_for(:home, HomeMapper)
  mapper_for(Post, SpecialMapper)
  mapper_for(->(author) { author.respond_to?(:name) && author.name == 'doh' }, AuthorMapper)
end

yaks.call(:home) # would map using HomeMapper
yaks.call(Post.new) # would map using PostMapper
yaks.call(Author.new(name: 'doh')) # would map using AuthorMapper
```

### derive_mapper_from_collection
This method will try various constant lookups based on naming. These all happen
in the configured namespace, which defaults to the Ruby top level.

If the first object in the collection has a class of `Widget`, and the
configured namespace is `API`, then these are tried in turn

* `API::WidgetCollectionMapper`
* `API::CollectionMapper`
* `Yaks::CollectionMapper`

Note that Yaks can only find a specific collection mapper for a type
if the collection passed to Yaks contains at least one element. If
it's important that empty collections are handled by the right mapper
(e.g. to set a specific `self` or `profile` link), then you have to be
explicit.

### derive_mapper_from_item

When using this method, the lookup happens based on the class name,
and will traverse up the class hierarchy in the configured namespace if
no suitable mapper is found. Take the following
code:
```ruby
module Stuff
  class Thing ; end
  class Widget < Thing ; end
end
```
The lookup we'll be done as followed.

* If the `namespace` option is set (to `Mappers` for example):
 * `Mappers::Stuff::WidgetMapper`
 * `Mappers::Stuff::ThingMapper`
 * `Mappers::Stuff::ObjectMapper`
 * `Mappers::Stuff::BasicObjectMapper`
 * `Mappers::WidgetMapper`
 * `Mappers::ThingMapper`

* If the `namespace` option is not set:
 * `Stuff::WidgetMapper`
 * `Stuff::ThingMapper`
 * `Stuff::ObjectMapper`
 * `Stuff::BasicObjectMapper`
 * `WidgetMapper`
 * `ThingMapper`

If none of these are found an error is raised.

### derive_mapper_from_association

When no mapper is specified for an association, then this method is
called to find the right mapper, based on the association name. In
case of `has_many` collections this is the "item mapper", the
collection mapper is resolved using `derive_mapper_from_object`.

By default the mapper class is derived from the name of the association, e.g.

```
has_many :widgets #=> WidgetMapper
has_one :widget   #=> WidgetMapper
```

It is always possible to explicitly set a mapper.

```
has_one :widget, mapper: FooMapper
has_many :widgets, collection_mapper: MyCollectionMapper, mapper: FooMapper
```

### derive_rel_from_association

Associations have a "rel", an IANA registered identifier or fully
qualified URI, that specifies how the object relates to the parent
document.

When configuring Yaks one can set a `rel_template`, that will be used
to generate these rels if not explicitly given. The `rel` placeholder
in the template will be substituted with the association name.

``` ruby
yaks = Yaks.new do
  rel_template "http://api.example.com/rel/{rel}"
end

class MyMapper < Yaks::Mapper
  # rel: "http://api.example.com/rel/widgets"
  has_many :widgets

  # rel: "http://api.example.com/rel/widget"
  has_one :widget
end
```

<a id="primitivizer"></a>

## Primitivizer

For JSON based formats, the "syntax tree" is merely a structure of Ruby primitives that have a JSON equivalent. If your mappers return non-primitive attribute values, you can define how they should be converted. For example, JSON has no notion of dates. If your mappers return these types as attributes, then Yaks needs to know how to turn these into primitives. To add extra types, use `map_to_primitive`

Here's an example with a custom `Currency` class, which can be represented as an integer.

```ruby
Yaks.new do
  map_to_primitive Currency do |currency|
    currency.to_i
  end
end
```

One notable use case is representing dates and times. The JSON
specification does not define any syntax for these, so the only
solution is to represent them either as numbers or strings. If you're
not sure what to do with these then the ISO8601 standard is a safe
bet. It defines a way to represent times and dates as strings, and is
also adopted by the W3C in [RFC3339](http://tools.ietf.org/html/rfc3339).

An alternative representation that is sometimes used is "unix time",
defined as the numbers of seconds passed since 1 January 1970.

Here's an example for a Rails app, so including ActiveSupport's `TimeWithZone`.

```ruby
Yaks.new do
  map_to_primitive Date, Time, DateTime, ActiveSupport::TimeWithZone, &:iso8601
end
```

`map_to_primitive` can also be used to transform alternative data
structures, like those from [Hamster](https://github.com/hamstergem/hamster),
into Ruby arrays and hashes. Use `call()` to recursively turn things into
primitives.

```ruby
Yaks.new do
  map_to_primitive Hamster::Vector, Hamster::List do |list|
    list.map do |item|
      call(item)
    end
  end
end
```

Yaks by default "primitivizes" symbols (as strings), and classes that include Enumerable (as arrays).


<a id="integration"></a>

## Integration

It is recommended to let Yaks handle the negotiation of media types,
so that consumer can request the format they prefer using an `Accept:`
header. To do this requires two steps: first make sure you pass the
rack env to Yaks, this way it will detect any `Accept` header and
honor it. While this is enough to get the correct serialized output,
it will likely be served up with the wrong `Content-Type` header by
your web framework.

To fix this, ask Yaks first for the "runner" for a given input, then
get the media type and serialized resource from the runner.

```ruby
# Tell your web framework about the supported formats
Yaks::Format.all.each do |format|
  mime_type format.format_name, format.media_type
end

# one time Yaks configuration
yaks = Yaks.new

# on each request
runner = yaks.runner(post, env: rack_env)
format = runner.format_name
output = runner.call
```


## Real World Usage

Yaks is used in production by

* [Ticketsolve](http://www.ticketsolve.com/). You can find an example API endpoint [here](http://leicestersquaretheatre.ticketsolve.com/api).
* Advertile Mobile for their product AppBounty (internal API)

## Demo

You can find an outdated example app at [Yakports](https://github.com/plexus/yakports), or browse the HAL api directly using the [HAL browser](http://yaks-airports.herokuapp.com/browser.html).

## Cookbook

See the [cookbook](COOKBOOK.md) for some usage examples taking from a real world app.

## Standards Based

Yaks is based on internet standards, including

* [RFC4288 Media types](http://tools.ietf.org/html/rfc4288)
* [RFC5988 Web Linking](http://tools.ietf.org/html/rfc5988)
* [RFC6906 The "profile" link relation](http://tools.ietf.org/search/rfc6906)
* [RFC6570 URI Templates](http://tools.ietf.org/html/rfc6570)
* [RFC4229 HTTP Header Field Registrations](http://tools.ietf.org/html/rfc4229).

## How to contribute

Run the tests, the examples, try it with your own stuff and leave your impressions in the issues.

To fix a bug

1. Fork the repo
2. Fix the bug, add tests for it
3. Push it to a named branch
4. Add a PR

To add a feature

1. Open an issue as soon as possible to gather feedback
2. Same as above, fork, push to named branch, make a pull-request

Yaks uses [Mutation Testing](https://github.com/mbj/mutant). Run `rake mutant` and look for percentage coverage. In general this should only go up.

## License

MIT License (Expat License), see [LICENSE](./LICENSE)

![](shaved_yak.gif)
