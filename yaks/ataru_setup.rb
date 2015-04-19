# "Require your project source code, with the correct path"

require "yaks"
require "hamster"

class Post < Struct.new(:id, :title, :author, :comments)
end

module MyAPI
end

class AuthorMapper < Yaks::Mapper
end

class PostMapper < Yaks::Mapper
end

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

  def post
    Post.new(7, "Yaks is Al Dente", nil, [])
  end

end
