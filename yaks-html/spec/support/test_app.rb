class TestApp < Sinatra::Base
  register Yaks::Sinatra

  class HomeMapper < Yaks::Mapper
    link 'http://myapi.example.com/rel/friends', '/friends'
  end

  class FriendMapper < Yaks::Mapper
    attribute :name

    def name
      object[:name]
    end

    form :poke do
      action '/poke/{name}'
      method 'POST'
      text :message
    end
  end

  class MessageMapper < Yaks::Mapper
    attribute :message do
      object[:message]
    end
  end

  configure_yaks do
    mapper_for :home, HomeMapper
    rel_template 'http://myapi.example.com/rel/{rel}'
  end

  get '/' do
    yaks :home
  end

  get '/friends' do
    yaks [{name: 'Matt'}, {name: 'Yohan'}, {name: 'Janko'}], item_mapper: FriendMapper
  end

  post '/poke/:name' do
    yaks({message: "You poked #{params[:name]}: #{params[:message]}"}, mapper: MessageMapper)
  end
end
