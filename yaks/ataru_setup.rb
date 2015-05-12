# "Require your project source code, with the correct path"

require "yaks"
require "hamster"

Post = Struct.new(:id, :title, :author, :comments)

module MyAPI
  Product = Struct.new(:id, :label)

  class ProductMapper < Yaks::Mapper
    attributes :id, :label
  end
end

class AuthorMapper < Yaks::Mapper
end

class CommentMapper < Yaks::Mapper
end

class PostMapper < Yaks::Mapper
  link :self, '/api/posts/{id}'

  attributes :id, :title

  has_one :author
  has_many :comments
end

class SpecialMapper; end

module Setup
  def setup
    # Do some nice setup that is run before every snippet
    # If you'd like to use instance variables define them here, e.g
    #  @important_variable_i_will_use_in_my_code_snippets = true
  end

  def teardown
    # Do some cleanup that is run after every snippet
  end

  # If you like local variables you can define methods, e.g
  # def number_of_wishes
  #  101
  # end

  def my_env
    {'something' => true}
  end
  alias_method :rack_env, :my_env

  def post
    Post.new(7, "Yaks is Al Dente", nil, [])
  end
  alias_method :foo, :post

  def product
    MyAPI::Product.new(42, "Shiny thing")
  end

  # # Tell your web framework about the supported formats
  # Yaks::Format.all.each do |format|
  #   mime_type format.format_name, format.media_type
  # end
  def mime_type(*_args)
  end
end
