module Yaks

BreakingChanges = {
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

end
