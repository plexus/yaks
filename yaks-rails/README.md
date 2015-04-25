Provide basic integration for using Yaks in Ruby on Rails. It gives you a top level `configure_yaks` method, and a `yaks` helper for use in routes.

This will register all media types known to Yaks, make sure the right one is picked based on the `Accept` header, and it will put the correct `Content-Type` header on the response.

