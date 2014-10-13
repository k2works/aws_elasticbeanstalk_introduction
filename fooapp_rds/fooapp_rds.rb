require "sinatra/activerecord"

class User < ActiveRecord::Base
  validates_presence_of :name
end

class FooappRds < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :public_folder => "public", :static => true

  get "/" do
    erb :welcome
  end

  get '/users' do
    @users = User.all
    erb :welcome
  end

  get '/users/:id' do
    @user = User.find(params[:id])
    erb :welcome
  end
end
