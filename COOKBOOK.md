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
