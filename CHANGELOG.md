# unreleased

* Introduce Yaks.new as the main public interface
* Remove Hamster dependency, Yaks new uses plain old Ruby arrays and hashes
* Remove RelRegistry and ProfileRegistry in favor of a simpler explicit syntax + policy based fallback
* add more policy derivation hooks, plus make DefaultPolicy template for rel urls configurable

# v0.3.0

* Allow partial expansion of templates, expand certain fields, leave others as URI template in the result.

# v0.2.0

* links can now take a simple for a template to compute a link just like an attribute