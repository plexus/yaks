Provide basic integration for using Yaks in Ruby on Rails. It gives you a top level `configure_yaks` method, and a `yaks` helper for use in routes.

This will register all media types known to Yaks, make sure the right one is picked based on the `Accept` header, and it will put the correct `Content-Type` header on the response.

``` ruby
class RootMapper < Yaks::Mapper
  link :self, '/'
  link :posts, '/posts'
end

class PostMapper < Yaks::Mapper
  attributes :title, :body, :date
  has_one :author
end

class ApplicationController
 include Rails::Yaks
  def index
    yaks nil, mapper: RootMapper
  end
end

class PostsController < ApplicationController
  def index
    yaks Post.all
  end
end
```
