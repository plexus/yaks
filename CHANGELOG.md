### Development
[full changelog](http://github.com/plexus/yaks/compare/v0.4.1...master)

* Make Yaks::CollectionMapper#collection overridable for pagination

# v0.4.1

* Change how env is passed to yaks.serialize to match docs
* Fix JSON-API bug (#18 reported by Nicolas Blanco)
* Don't pluralize has_one association names in JSON-API

# v0.4.0

* Introduce after {} post-processing hook
* Streamline interfaces and variable names, especially the use of `call`
* Improve deriving mappers automatically, even with Rails style autoloading
* Give CollectionResource a members_rel, for HAL-like formats with no top-level collection concept
* Switch back to using `src` and `dest` as the rel-template keys, instead of `association_name`
* deprecate `mapper_namespace` in favor of `namespace`

# v0.4.0.rc1

* Introduce Yaks.new as the main public interface
* Fix JsonApiSerializer and make it compliant with current spec
* Remove Hamster dependency, Yaks new uses plain old Ruby arrays and hashes
* Remove `RelRegistry` and `ProfileRegistry` in favor of a simpler explicit syntax + policy based fallback
* Add more policy derivation hooks, plus make `DefaultPolicy` template for rel urls configurable
* Optionally take a Rack env hash, pass it around so mappers can inspect it
* Honor the HTTP Accept header if it is present in the rack env
* Add map_to_primitive configuration option

# v0.3.0

* Allow partial expansion of templates, expand certain fields, leave others as URI template in the result.

# v0.2.0

* links can now take a simple for a template to compute a link just like an attribute