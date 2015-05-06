# Yaks Cookbook

## Represent Date/Time objects as iso8601

``` ruby
$yaks = Yaks.new do
  map_to_primitive Date, Time, DateTime, ActiveSupport::TimeWithZone, &:iso8601
end
```

## Make Yaks' HTML format play nice with CSRF protection

Minimum version when using Rack::Protection

``` ruby
$yaks = Yaks.new do
  after :format, :add_csrf_token do |result, env|
    next result unless result.is_a?(Hexp::Node) && env.key?('rack.session')

    session = env['rack.session']
    session[:csrf] ||= SecureRandom.hex(32)
    token = session[:csrf]

    result.replace 'form' do |form|
    form.append(H[:input, type: :hidden, name: 'authenticity_token', value: token])
    end
  end
end
```

Version that covers all cases when using a Rack::Protection protected
API mounted inside a Rails app.

``` ruby
$yaks = Yaks.new do
  after :format, :add_csrf_token do |result, env|
    next result unless result.is_a?(Hexp::Node) && env.key?('rack.session')

    # Rails uses '_csrf_token' as a key. Rack::Protection uses
    # :csrf, but will detect and use '_csrf_token' if :csrf is
    # absent. This works fine as long as a call to Rails is made
    # before a call to the API is made. When using the HTML
    # rendering of the API on an empty session and afterwards
    # switching to Rails though, the '_csrf_token' and :csrf
    # values will differ, causing Rack::Protection to reject
    # valid API calls. Hence this little dance to prevent that.

    session = env['rack.session']
    session[:csrf] ||= session['_csrf_token'] || SecureRandom.hex(32)
    session['_csrf_token'] ||= session[:csrf]
    token = session[:csrf]

    result.replace 'form' do |form|
    form.append(H[:input, type: :hidden, name: 'authenticity_token', value: token])
    end
  end
```

## Make Yaks' HTML format work with PUT/DELETE/etc.

If you're using `Rack::MethodOverride` or something similar, you could
drop this in your Yaks config to convert forms so they will work in a
browser.

``` ruby
after :format, :html_form_methods do |result, env|
  next result unless result.is_a?(Hexp::Node)
  result.replace('[method="PUT"],[method="DELETE"],[method="PATCH"]') do |form|
    form
      .append(H[:input, type: "hidden", name: "_method", value: form[:method]])
      .attr("method", "POST")
  end
end
```

## Implement Pagination

In a hypermedia API the typical way to provide pagination is by adding
"previous" and "next" links on a collection. You can do this by
implementing your own CollectionMapper

```
module Mappers
  class CollectionMapper < Yaks::CollectionMapper
    PAGE_SIZE = 50

    link :previous, -> { previous_link }
    link :next,     -> { next_link     }

    def params
      Rack::Request.new(env).params
    end

    def offset
      params.fetch('offset') { 0 }.to_i
    end

    alias full_collection collection

    def collection
      # You can implement more efficient page slicing based on DB
      # layer you're using
      full_collection.drop(offset).take(PAGE_SIZE)
    end

    def count
      full_collection.count
    end

    def previous_link
      if offset > 0
        URITemplate.new("#{env['PATH_INFO']}{?offset}").expand(offset: [offset - PAGE_SIZE, 0].max)
      end
    end

    def next_link
      if offset + page_size < count
        URITemplate.new("#{env['PATH_INFO']}{?offset}").expand(offset: offset + PAGE_SIZE)
      end
    end
  end
end
```

You can pass this mapper explicitly when calling yaks:
`yaks.call(collection, mapper: MyCollectionMapper)`, or leverage the
default policy which gives you several options for hooking into mapper
resolution.

* When implementing a `CollectionMapper` inside your configured mapper
  namespace, or at the top level if no namespace is confgured, Yaks
  will use that instead of its vanilla collection mapper

* If you're serializing collections of a specific type, you can implement a specific mapper for that. E.g. if you want paging for hypothetical `DatabaseQuerySet`, you can implement a `DatabaseQuerySetMapper`

* You can make a `PagedCollection` decorator class, and provide a `PagedCollectionMapper`. This is a great pattern because you can put more of the paging logic inside that object, and override it in subclasses, e.g. to date per month, offset, page, etc.
