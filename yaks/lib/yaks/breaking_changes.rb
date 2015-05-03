module Yaks
# These are displayed in a post-install message when installing the
# gem to aid upgraiding

BreakingChanges = {

    '0.7.6' => %q~
Breaking Changes in Yaks 0.7.6
==============================
Breaking change: using a symbol instead of link template no longer
works, use a lambda.

    link :foo, :bar

Becomes

    link :foo, ->{ bar }

Strictly speaking the equivalent version would be `link :foo, ->{
load_attribute(:bar) }`. Depending on if `bar` is implemented on the
mapper or is an attribute of the object, this would simplify to `link
:foo, ->{ bar }` or `link :foo, ->{ object.bar }` respectively.

The `href` attribute of a control has been renamed `action`, in line
with the attribute name in HTML. An alias is available but will output
a deprecation warning.
~,

    '0.7.0' => %q~
Breaking Changes in Yaks 0.7.0
==============================
Yaks::Resource#subresources is now an array, not a hash. The rel is
stored on the resource itself as Yaks::Resource#rels (an array). This
should only be of concern if you implement custom output formats

The general signature of all processing steps (mapper, formatter,
hooks) has changed to incldue a second parameter, the rack env. If you
have custom implementations of any of these, or hooks that are not
specified as ruby blocks, you will need to take this into account
~,

    '0.5.0' => %q~

Breaking Changes in Yaks 0.5.0
==============================

Yaks now serializes its output, you no longer have to convert to JSON
yourself. Use `skip :serialize' to get the old behavior, or
`json_serializer` to use a different JSON implementation.

The single `after' hook has been replaced with a set of `before',
`after', `around' and `skip' hooks.

If you've created your own subclass of `Yaks::Format' (previously:
`Yaks::Serializer'), then you need to update the call to
`Format.register'.

These are potentially breaking changes. See the CHANGELOG and README
for full documentation.

~,

    '0.4.3' => %q~

Breaking Changes in Yaks 0.4.3
==============================

Yaks::Mapper#filter was removed, if you override this method in your
mappers to conditionally filter attributes or associations, you will
have to override #attributes or #associations instead.

When specifying a rel_template, now a single {rel} placeholder is
expected instead of {src} and {dest}.

There are other internal changes. See the CHANGELOG and README for full
documentation.

~
}

BreakingChanges['0.4.4'] = BreakingChanges['0.4.3']
BreakingChanges['0.7.1'] = BreakingChanges['0.7.0']
end
