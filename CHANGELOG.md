### master
[full changelog](http://github.com/plexus/yaks/compare/v0.8.3...master)

Some changes to bring JSONAPI formatting more in line with 1.0 format
 - Top level key must be named 'data' rather than the resource type
 - The resource name myst be included in a 'type' attribute

Started a REader for JSONAPI, which can build a resource from JSONAPI input.

Add if: options to Form::Field, Form::Fieldset, and Form::Field
option, just as on links, associations, and forms.

Allow form field details to be expressed in a block, and allow
Configurable "setters" to take a block instead of a direct argument.

``` ruby
text :first_name,
  label: 'views.checkout.first_name',
  required: true,
  value: ->{ customer_attribute(:first_name) }
```

becomes

```
text :first_name do
  required true
  label 'views.checkout.first_name'
  value { customer_attribute(:first_name) }
end
```

This makes the DSL more consistent, since e.g. `label` could already
be set in this way, but not `value` or `required`.

Prevent `:if` on a form field to be rendered as a form element
attribute.

### v0.8.3

The default policy for resolving mappers will now look up superclass
names of the object being serialized, so you can define a single
mapper to handle a class hierarchy.

### v0.8.2

Various improvements to the HTML formatter

- use the form name as a title if there's no title
- remove the link styling on rels to indicate they are purely
  identifiers
- link IANA registered rels (indicated by using a symbol) to the IANA
  list
- style the hierarchy in a cleaner way by using a gray left border
  rather than complete boxes
- Add a header that shows the current request method/path
- Add a footer that shows the yaks version
- show the name/value of hidden form fields
- get rid of the all the border-radius, try a new color scheme

### v0.8.1

Add `disabled` as a possible attribute of a select option, so you can
render form select controls with disabled options.

### v0.8.0

Allow to use procs for dynamic values in "option" form elements (as
used inside a "select"). This makes the form API more consistent.

Add an `:if` option to links, to only render them upon a certain
condition.

Add an `:if` option to forms, and a corresponding `condition` method
(it's tricky to have a method called `if`), to only render them upon a
certain condition.

Add an `:if` option to associtions, to only render them upon a certain
condition.

### 0.8.0.beta2

In form select fields, allow the attributes of options to be generated
dynamically by passing procs, in line with other form related
attributes

### 0.8.0.beta1

Improved form support, HTML form rendering, CJ support.

### 0.8.0.alpha

Improved Collection+JSON support, dynamically generated form fields.

#### Collection+JSON

Carles Jove i Buxeda has done some great work to improve support for Collection+JSON, GET forms are now rendered as CJ queries.

#### Dynamic Form Fields

A new introduction are "dynamic" form fields. Up to now it was hard to generate forms based on the object being serialized. Now it's possible to add dynamic sections to a Form definition. These will be evaluated at map-time, they receive the object being mapped, and inside the syntax for defining form fields can be used.

```
form :checkout do
  text :name
  text :lastname

  dynamic do |object|
    object.shipping_options.each do |shipping|
      radio shipping.type_name, title: shipping.description
    end
  end
end
```

#### Fieldset and Legend

Support for the fieldset element type has been added, which works as you would expect

```
form :foo do
  fieldset do
    legend "Hello"
    text :field_1
  end
end
```

#### Remove links

A link defined in a mapper can be removed in a derived mapper. This is useful when you have a base mapper defining for example 'self' or 'profile' links, but for some derived mappers you don't want these in the output.

```
class BaseMapper
  link :self, "/api/{mapper_name}/{id}"
end

class FooMapper < BaseMapper
  link :self, remove: true
end
```

#### Deprecations

Internally there the DSL/Config mechanisms have been made more consistent. Yaks::Config is now immutable, much like Yaks::Mapper::Config. Attributes-based classes no long have arity-based hybrid getter/setters. Instead use `with(attr: val)` to set a value.

Because of this work, two methods on Yaks::Config are considered deprecated. You will get a warning when using the old name.

* json_serializer, use serializer(:json, &...)
* namespace, use mapper_namespace

#### Experimental read/write support

Some work has happened on read/write support, but this is not considered stable yet.

### 0.7.7

General extension and improvements to form handling.

Add top level links in Collection+JSON (Carles Jove i Buxeda)

The mapper DSL method "control" has been renamed to "form". There is a
deprecated alias available.

Add Yaks::Resource#find_form for querying a resource for an embedded
form by name.

Introduce yaks.map() so you can only call the mapping step without
running the whole pipeline.

### 0.7.6

Much expanded form support, simplified link DSL, pretty-print objects
to Ruby code.

Breaking change: using a symbol instead of link template no longer
works, use a lambda.

    link :foo, :bar

Becomes

    link :foo, ->{ bar }

Strictly speaking the equivalent version would be `link :foo, ->{
load_attribute(:bar) }`. Depending on if `bar` is implemented on the
mapper or is an attribute of the object, this would simplify to `link
:foo, ->{ bar }` or `link :foo, ->{ object.bar }` respectively.

The form control DSL has been expanded, instead of `field type:
'text'` and similar there are now aliases, e.g. `text :name, value:
'foo'`.

All attributes on the form control itself, and on fields, now
optionally take a lambda (any `#to_proc`-able) for dynamic
content. e.g.

    control :add_product do
      method 'POST'
      action ->{ '/cart/#{cart.id}/line_items' }
      hidden :product_id, value: -> { product.id }
      number :quantity, value: 0
    end

As with lambdas used for links, in case of a zero-arity lambda these
evaluate with `self` being the mapper. If the lambda takes an argument
the argument will be the mapper, and the lambda is evaluated as a
closure.

The `href` attribute of a control has been renamed `action`, in line
with the attribute name in HTML. An alias is available but will output
a deprecation warning.

The Yaks::Resource#pp method has been lifted into Attributes so it's
available on most immutable Yaks objects. It has also been adapted to
produce, in most cases, output that is valid Ruby code.

### 0.7.5

Add the :replace option to link specifications. When used on a link
when another link of the same rel was specified previously, then the
current link will replace the one (and any other) that was specified
earlier.

Use case:

    class BaseMapper < Yaks::Mapper
      link :self, '/api/{mapper_name}/{id}'
    end

    class CartMapper < BaseMapper
      link :self, '/api/cart', :replace => true
    end


### 0.7.4

Fix a regression in around hooks introduced in 0.7.0.

Improve pretty printing (Yaks::Resource#pp)

### 0.7.3

yaks-sinatra: Allow passing extra Yaks options to the helper method

### 0.7.2

Allow controls to use the same expansion mechanisms that are available
in links, i.e. URI templates, symbol referring to a method. Added
procs to that list as well.

### 0.7.1

Bugfix in CollectionMapper.

### 0.7.0

#### Introduces yaks-sinatra

For easier Sinatra integration. See the respective README for more info.

#### Move the rel of subresource into a resource itself

Before the subresources in a Yaks::Resource were stored in a hash,
keyed by rel. Now the rel is stored as a property of the resource, and
the subresources are a simple array. This opens the door to formats
that support multiple rels on a resource, and simplifies things as a
preparatory step towards bi-directional mapping.

This change is mostly transparent to the user, but when implementing
custom output formats or doing testing on the resulting Resource
instances, you might have to update your code.

#### Pass the rack env to steps and hooks

Yaks is a pipeline where each step implements the `call`
method. Before `call` always received one argument, the previous
transformation step's result. Now it receives the Rack env as a second
argument.

This also applies to before/after/around hooks, although if they are
specified as ruby blocks then no change is needed, the second argument
will be ignored.

#### Handle URI instances

After formatting for a JSON output format (e.g. HAL), but before
actually serializing to JSON, all data needs to be of a type that has
a JSON equivalent, or needs to be handled explicitly with a conversion
(known as "primitivizing"). instances of `URI` have been added to this
list, they will automatically be represented as JSON strings.

### 0.6.2

Improvements to yaks-html: render form controls, make output prettier.

### 0.6.1

Make sure Resource, NullResource, and CollectionResource have
identical public APIs.

Create a base Yaks::Error class, and derived classes for specific
error categories. This should make it easier to handle errors
originating in Yaks. Note that not all code makes use of these yet, so
you might still get a StandardError in some cases.

### 0.6.0

v0.6.0 saw some big internal overhaul to make things cleaner and more
consistent. It also introduced some new features.

#### Form controls

We already had templated links which form a limited way of generating
parameterized requests. Form controls are more like full HTML forms,
e.g.

``` ruby
class UserMapper < Yaks::Mapper
  control :create do
    href         "/foo"
    method       "POST"
    content_type "application/x-www-form-urlencoded"

    field :first_name, label: "First name"
    field :last_name,  label: "Last name"
  end
end
```

These are also called actions in some formats. At the moment only one
format renders these, a new format called HALO which is en extension
of HAL, loosely based on an example by Mike Kelly on how HAL could be
extended for this purpose.

#### Introduce a HTML output format

Provided as a separate gem, `yaks-html` allows Yaks to generate a
version of your API that can be browsed from any web browser. This is
still very rough around the edges.

### 0.5.0

* Yaks now serializes (returns a string), instead of returning a data
  structure. This is a preparatory step for supporting non-JSON
  formats. To get the old behavior back, do this

``` ruby
yaks = Yaks.new do
  skip :serialize
end
```

* The old `after` hook has been removed, instead there are now generic hooks for all steps: `before`, `after`, `around`, `skip`; `:map`, `:format`, `:primitivize`, `:serialize`.

* By default Yaks uses `JSON.pretty_generate` as a JSON unparser. To use something else, for example `Oj.dump`, do this

``` ruby
yaks = Yaks.new do
  json_serializer &Oj.method(:dump)
end
```

* Mapping a non-empty collection will try to infer the type, and hence rel of the nested items, based on the first object in the collection. This is only relevant for formats like HAL that don't have a top-level collection representation, and only matters when mapping a collection at the top level, not when mapping a collection from an association.

* Collection+JSON uses a link's "title" attribute to output a link's "name", to better correspond with other formats

* When registering a custom format (Yaks::Format subclass), the signature has changed

``` ruby
# 0.4.3
Format.register self, :collection_json, 'application/vnd.collection+json'

# 0.5.0
register :collection_json, :json, 'application/vnd.collection+json'
```

* `yaks.call` is now the preferred interface, rather than `yaks.serialize`, although there are no plans yet to remove the alias.

* The result of a call to `Yaks.new` now responds to `to_proc`, so you can treat it as a Proc/Symbol, e.g. `some_method &yaks`

* Improved YARD documentation

* 100% mutation coverage :trumpet: :tada:

### 0.4.3

* when specifying a rel_template, instead of allowing for {src} and {dest} fields, now a single {rel} field is expected, which corresponds more with typical usage.

```ruby
Yaks.new do
  rel_template 'http://my-api/docs/relationships/{rel}'
end
```

* Yaks::Serializer has been renamed to Yaks::Format

* Yaks::Mapper#{map_attributes,map_links,map_subresource} signature has changed, they now are responsible for adding themselves to a resource instance.

```ruby
class FooMapper < Yaks::Mapper
  def map_attributes(resource)
    resource.update_attributes(:example => 'attribute')
  end
end
```

* Conditionally turn associations into links

```ruby
class ShowMapper < Yaks::Mapper
  has_many :events, href: '/show/{id}/events', link_if: ->{ events.count > 50 }
end
```

* Reify `Yaks::Mapper::Attribute`

* Remove `Yaks::Mapper#filter`, instead override `#attributes` or `#associations` to filter things out, for example:

```ruby
class SongMapper
  attributes :title, :duration, :lyrics
  has_one :artist
  has_one :album

  def minimal?
    env['HTTP_PREFER'] =~ /minimal/
  end

  def attributes
    if minimal?
      super.reject {|attr| attr.name.equal? :lyrics } # These are instances of Yaks::Mapper::Attribute
    else
      super
    end
  end

  def associations
    return [] if minimal?
    super
  end
end
```

* Give Attribute, Link, Association a common interface : `add_to_resource(resource, mapper, context)`
* Add persistent update methods to `Yaks::Resource`

### v0.4.2

* JSON-API: render self links as href attributes
* HAL: render has_one returning nil as null, not as {}
* Keep track of the mapper stack, useful for figuring out if mapping the top level response or not, or for accessing parent
* Change Serializer.new(resource, options).serialize to Serializer.new(options).call(resource) for cosistency of "pipeline" interface
* Make Yaks::CollectionMapper#collection overridable for pagination
* Don't render links from custom link methods (link :foo, :method_that_generates_url) that return nil

### v0.4.1

* Change how env is passed to yaks.serialize to match docs
* Fix JSON-API bug (#18 reported by Nicolas Blanco)
* Don't pluralize has_one association names in JSON-API

## v0.4.0

* Introduce after {} post-processing hook
* Streamline interfaces and variable names, especially the use of `call`
* Improve deriving mappers automatically, even with Rails style autoloading
* Give CollectionResource a members_rel, for HAL-like formats with no top-level collection concept
* Switch back to using `src` and `dest` as the rel-template keys, instead of `association_name`
* deprecate `mapper_namespace` in favor of `namespace`

### v0.4.0.rc1

* Introduce Yaks.new as the main public interface
* Fix JsonApiSerializer and make it compliant with current spec
* Remove Hamster dependency, Yaks new uses plain old Ruby arrays and hashes
* Remove `RelRegistry` and `ProfileRegistry` in favor of a simpler explicit syntax + policy based fallback
* Add more policy derivation hooks, plus make `DefaultPolicy` template for rel urls configurable
* Optionally take a Rack env hash, pass it around so mappers can inspect it
* Honor the HTTP Accept header if it is present in the rack env
* Add map_to_primitive configuration option

## v0.3.0

* Allow partial expansion of templates, expand certain fields, leave others as URI template in the result.

## v0.2.0

* links can now take a simple for a template to compute a link just like an attribute
