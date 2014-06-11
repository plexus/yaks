# v0.4.0 (unreleased)

* Introduce Yaks.new as the main public interface
* Fix JsonApiSerializer and make it compliant with current spec
* Remove Hamster dependency, Yaks new uses plain old Ruby arrays and hashes
* Remove RelRegistry and ProfileRegistry in favor of a simpler explicit syntax + policy based fallback
* Add more policy derivation hooks, plus make DefaultPolicy template for rel urls configurable
* Optionally take a Rack env hash, pass it around so mappers can inspect it
* Honor the HTTP Accept header if it is present in the rack env
* Add map_to_primitive configuration option

# v0.3.0

* Allow partial expansion of templates, expand certain fields, leave others as URI template in the result.

# v0.2.0

* links can now take a simple for a template to compute a link just like an attribute