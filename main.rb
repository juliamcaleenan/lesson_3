require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do 
  "Welcome to Blackjack!"
end

get '/game' do
  erb :game
end

get '/nested' do
  erb :"test/nest_test"
end


