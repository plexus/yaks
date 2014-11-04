# Identifiers

In Yaks, and Hypermedia message formats in general, a number of
different types of identifiers are used. Some are full URIs and
correspond with well defined specs. Some are just short identifers
that are easy to program with.

Understanding these types of identifiers is key to creating a unifying
model of a "Resource" that can be shared across output formats. We
want to unify as much as possible across formats, without conflating
things that are really not the same.

This document reflects my current limited understanding of things,
based on possibly incorrect assumptions. Feedback is more than
welcome.

## rels

As used in HTML and Atom, these identifiers say what the relationship
is between a resource and another resource it links to. There is a
[registry of names](http://www.iana.org/assignments/link-relations/link-relations.xhtml),
e.g. self, next, profile, stylesheet. Custom rels need to be fully
qualified URLs. Keep in mind that these are simply opaque identifiers,
but by using a known protocol like http they can be used to point at
documentation.

Some examples

```
copyright
stylesheet
http://api.example.com/rel/author
http://api.example.com/api-docs/relationships#comment
custom_scheme:foo
/order
```

The last example is a relative URL, which would have to be expanded against the source URL of the document it is mentioned in.

In Yaks both links and subresources are specified with their rel(ationship).

```ruby
class PersonMapper < Yaks::Mapper
  link :self, '/people/{id}'
  link 'http://api.example.com/rels#friends', '/people/{id}/friends'

  has_one :address, rel: 'http://api.example.com/rels#address'
end
```

For subresources the rel can be omitted, in which case it will be inferred based on the rel_template:

```ruby
$yaks = Yaks.new do
  rel_template 'http://api.example.com/rels/{dest}'
end
```

Links and subresources are rendered keyed by rel in HAL and Collection+JSON. JSON-API renders `self` links as the `href` of a resource.

## profiles

A specific IANA registered rel type is profile.

> Profile: Identifying that a resource representation conforms to a certain profile, without affecting the non-profile semantics of the resource representation.

Profile basically adds a layer of semantics on top of the hypermedia message format (e.g. HAL, Collection+JSON), which in turns defines semantics on top of a serialization format (JSON, XML, EDN). Loosely speaking it could be seen as the "type" or "class". For example if you know the profile of a resource, you might know you can expect to find a "name", "date_of_birth", or "post_body" field.

## "type"

Despite the appealing rigor of having fully qualified URIs to identify things, sometimes you just want to call a person a `person`. In Yaks we call these short identifier the *type* for lack of a better word. In some cases, notably JSON-API, they are used literally in the output. More often they are used to derive full URIs based on a template.

The type of a mapper is inferred from its class name, but can be set explicitly as well.

```ruby
class CatMapper < Yaks::Mapper
end

# type = "cat"
```

```ruby
class CatMapper < Yaks::Mapper
  type 'feline'
end

# type => "feline"
```

## rdf class

RDF (Resource Description Framework) is a set of specifications for use in "semantic web" applications. RDF is based on "ontologies" that precisely define a "vocabulary" of "classes" and "predicates". An example class identifier for all Merlot wines could be

> http://www.w3.org/TR/2004/REC-owl-guide-20040210/wine#Merlot

(source [wikipedia](http://en.wikipedia.org/wiki/Resource_Description_Framework))

Not currently used by Yaks, but might become important when implementing support for JSON-LD or other RDF serialization formats.

## CURIES

CURIES are "compact uris". The HAL format uses this so it can have the rigor of fully specified rels, with the ease of use of short-name "type" identifiers. The mechanism is similar to how one specifies and uses XML namespaces.

From the HAL spec:

```json
{
    "_links": {
        "self": { "href": "/orders" },
        "curies": [{ "name": "ea", "href": "http://example.com/docs/rels/{rel}", "templated": true }],
        "next": { "href": "/orders?page=2" },
        "ea:find": {
            "href": "/orders{?id}",
            "templated": true
        },
        "ea:admin": [{
            "href": "/admins/2",
            "title": "Fred"
        }, {
            "href": "/admins/5",
            "title": "Kate"
        }]
    }
}
```

In this case "ea:find" is just a shorthand for "http://example.com/docs/rels/find".
