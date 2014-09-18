### Development
[full changelog](http://github.com/plexus/yaks/compare/v0.5.0...master)

### 0.5.0

* Yaks now serializes (returns a string), instead of returning a data structure. This is a preparatory step for supporting non-JSON formats. To get the old behavior back, do this

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

* When registering a custom format (Yaks::Format subclass), the signature has changed

``` ruby

* Collection+JSON uses a link's "title" attribute to output a link's "name", to better correspond with other formats

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
