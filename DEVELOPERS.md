# Yaks Dev Docs

This document is for when you want to hack on Yaks itself, or better
understand its internals. To simply use it, consult the README.

## Attribs

You'll find that most classes in Yaks include an instance of
`Attribs`, for example

``` ruby
class Yaks::Resource::Link
  include Attribs.new(:rel, :uri, options: {})
end
```

You can think of this (as a starting point) as replacing
`attr_reader`, by adding this line instances of `Link` will have
getter methods for `rel`, `uri`, and `options`. But that's really just
scratching the surface.

`Attribs` relies on Anima, so you get the same things as
using `include Anima.new`

* a hash-based constructor
* getters
* equality checks
* `to_h`

``` ruby
link = Yaks::Resource::Link.new(rel: :self, uri: '/api/cart', options: {templated: false})

link.rel # => :self
link.to_h # => {:rel=>:self, :uri=>"/api/cart", :options=>{:templated=>false}}

link == Yaks::Resource::Link.new(link.to_h) # => true
```

These last two are important because they make these objects behave
like "value objects". They are fully defined by their properties, not
by their (object) identity.

Note that there are no setters, these objects are immutable.

There are some other things that `Attribs` adds that make it
a pleasure to work with these objects.

* default values
* `with` method to create updates
* `with_x` convenience methods
* `pp` method for representing instances as valid Ruby code
* `append_to` method
* `to_h_compact` method

You can include default values for properties in `Attribs.new(...)`, for example the options of a `Link` default to `{}`.

`with` (see
[this discussion](https://gist.github.com/plexus/42c6c9c63212182ee440)
about why that name was chosen), will create a new object, with
certain properties replaced.

``` ruby
link2 = link.with(uri: '/foo/bar')

link  # => #<Yaks::Resource::Link rel=:self uri="/api/cart" options={:templated=>false}>
link2 # => #<Yaks::Resource::Link rel=:self uri="/foo/bar" options={:templated=>false}>
```

For each property `foo` there's also `with_foo`, so `x.with(foo: 'bar')` is the same as `x.with_foo('bar')`

`pp` recursively turns nested `Attribs` based objects into nicely
format, valid Ruby code. This is great for debugging, and very helpful
when writing test cases.

<a id="mapper_config_example"></a>

``` ruby
class FooMapper < Yaks::Mapper
  attributes :a, :b
  link :self, '/api/foo'
  has_many :baz
  form :bar do
    text :name
    text :age
  end
end

puts FooMapper.config.pp

# -- output --
Yaks::Mapper::Config.new(
  attributes: [
    Yaks::Mapper::Attribute.new(name: :a),
    Yaks::Mapper::Attribute.new(name: :b)
  ],
  links: [
    Yaks::Mapper::Link.new(rel: :self, template: "/api/foo", options: {})
  ],
  associations: [
    Yaks::Mapper::HasMany.new(name: :baz, collection_mapper: nil)
  ],
  forms: [
    Yaks::Mapper::Form.new(
      config: Yaks::Mapper::Form::Config.new(
        name: :bar,
        fields: [
          Yaks::Mapper::Form::Field.new(name: :name, type: :text),
          Yaks::Mapper::Form::Field.new(name: :age, type: :text)
        ]
      )
    )
  ]
)
```

Because of the common case where new objects need to be added to a
list, e.g. a new link, association, form, to the respective property,
there's a `append_to` convenience method for that.

``` ruby
config = Yaks::Mapper::Config.new
config = config.append_to(:attributes, Yaks::Mapper::Attribute.new(name: :a))
config = config.append_to(:attributes, Yaks::Mapper::Attribute.new(name: :b))
puts config.pp

# -- output --
Yaks::Mapper::Config.new(
  attributes: [
    Yaks::Mapper::Attribute.new(name: {:name=>:a}),
    Yaks::Mapper::Attribute.new(name: {:name=>:b})
  ]
)
```

Finally `to_h_compact` is similar to `to_h`, but won't output values that are the same as the defaults. So it's the minimal hash for which `foo == foo.class.new(foo.to_h_compact)` holds true.

## The Mapper DSL

Now that we know that most objects in Yaks behave in a uniform way, we
can leverage that to create the Yaks mapper DSL.

As demonstrated in the [example above](#mapper_config_example), most
methods like `link`, `has_many`, or `fieldset` simply instantiate an
object of a certain type, and add it to a "config" object. For a form
`text` input field, the config object is a `Form::Config`, held by the
form instance. At the top-level where we have attributes, links, and
associations, this config object is an instance of
`Yaks::Mapper::Config` held by the mapper subclass. When configuring
Yaks itself (through `Yaks.new do ...`), you are creating a
`Yaks::Config`, etc.

Because the objects created by the DSL all use `Attribs`,
their constructor takes a Hash. For the DSL we often prefer positional
arguments, however. E.g. `form :create` instead of `form name:
:create`. To bridge this gap classes like `Form` implement a class
method `create`, with the same signature as the DSL method.

Because all these classes implement `create`, we can now generate the
DSL methods in a generic way. This is where `Yaks::Configurable` comes
in.

## Yaks::Configurable

Here's how `Yaks::Mapper` starts

``` ruby
module Yaks
  class Mapper
    extend Configurable

    def_add :link,      create: Link,      append_to: :links
    def_add :has_one,   create: HasOne,    append_to: :associations
    def_add :has_many,  create: HasMany,   append_to: :associations
    def_add :attribute, create: Attribute, append_to: :attributes
    def_add :form,      create: Form,      append_to: :forms

    def_set :type

    def_forward :attributes => :add_attributes
    def_forward :append_to
```

The `def_add` "macro"[[1](#macro_footnote)] provided by `Yaks::Configurable` will generate a
method which

* creates an instance of certain class by calling `KlassName.create(...)`
* update `config` to a new config which has the instance appended to
  `config.links`

For the case where a DSL method simply needs to overwrite a certain
config attribute, use `def_set`.

For more involved cases you can implement methods on the Config object
that will "update" it in a specific way, returning the updated
instance (remember these are all immutable). In that case you generate
a DSL method which "forwards" to the config object, hence `def_forward`

## Builder

In the case of `Yaks::Mapper`, the config object is stored on each
mapper subclass. In other cases the configuration isn't class based
though, but instance based. For example, both a `Yaks::Form` and a
`Yaks::Form::Fieldset` both have a `Yaks::Form::Config` instance as an
attribute. Creating form fields will add them to this config.

The block passed to the `form` DSL method will be passed on to
`Form.create`. Inside the block a very similar DSL is used as that on
a Mapper, but we don't have a class level evaluation context.

Instead we create a `Yaks::Builder` and use the `Yaks::Configurable`
"macros" to declare how the DSL in this context functions. Finally we
ask the builder to evaluate the block, updating the form's config.

``` ruby
module Yaks::Mapper::Form

  ConfigBuilder = Builder.new(Config) do
    def_set :action, :title, :method, :media_type
    def_add :field, create: Field::Builder, append_to: :fields
    def_add :fieldset, create: Fieldset, append_to: :fields
    # ...
  end

  def self.create(*args, &block)
    args, options = extract_options(args)
    options[:name] = args.first if args.first.is_a? Symbol

    config = Config.new(options)
    config = ConfigBuilder.build(config, &block)

    new(config: config)
  end

  # ...
end
```

The builder takes an initial config object, and then evaluates the
block, keeping track of the updated config as it evaluates DSL
methods. Finally you get the updated config object back. [[2](#state_monad_footnote)]


### footnotes

<a id="macro_footnote">[1]</a> I strongly dislike calling all Ruby
class-level methods "macros", especially when they have little to
nothing in common with "real" (i.e. syntax tranforming read-time
functions) macros. In this case what they achieve is very similar to
what you would do with a "real" macro, so I'm rolling with it, adding
sarcastic "quotes" to express my self-loathing in doing so.

<a id="state_monad_footnote">[2]</a> You can think of the Builder as a
state monad. I'm sure that helps.
