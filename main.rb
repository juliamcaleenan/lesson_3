require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => '93jf73heiw0' 

INITIAL_POT_AMOUNT = 500

helpers do
  def calculate_total(hand)
    total = 0
    hand.each do |card|
      if card[1] == "Ace"
        total += 11
      elsif card[1].to_i == 0
        total += 10
      else
        total += card[1]
      end
    end

    hand.select { |card| card[1] == "Ace"}.count.times do
      total -= 10 if total > 21
    end

    total
  end

  def winner!(msg)
    @winner = "<strong>#{session[:player_name]} wins!</strong> #{msg}"
    @player_turn = false
    @play_again = true
  end

  def loser!(msg)
    @loser = "<strong>#{session[:player_name]} loses!</strong> #{msg}"
    @player_turn = false
    @play_again = true
  end

  def tie!(msg)
    @tie = "<strong>It's a tie!</strong> #{msg}"
    @player_turn = false
    @play_again = true
  end

end

before do
  @player_turn = true
  @dealer_turn = false
end

get '/' do 
  session[:player_money] = INITIAL_POT_AMOUNT
  erb :set_name
end

post '/set_name' do
  if params[:player_name].empty?
    @error = "Please enter a valid name"
    halt erb :set_name
  end
  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/bet' do
  if session[:player_money] == 0
    @error = "#{session[:player_name]} has no money left!"
    halt erb :game_over
  end
  erb :bet
end

post '/bet' do
  if (params[:bet_amount].to_i <= session[:player_money]) && (params[:bet_amount].to_i > 0)
    session[:bet_amount] = params[:bet_amount].to_i
    redirect '/game'
  elsif params[:bet_amount].to_i > session[:player_money]
    @error = "#{session[:player_name]} only has $#{session[:player_money]} in total!"
    erb :bet
  else
    @error = "Please enter a valid amount."
    erb :bet
  end
end

get '/game' do
  session[:deck] = []
  ["Clubs", "Diamonds", "Hearts", "Spades"].each do |suit|
    (2..10).each do |value|
      session[:deck] << [suit, value]
    end
    ["Jack", "Queen", "King", "Ace"].each do |value|
      session[:deck] << [suit, value]
    end
  end
  session[:deck].shuffle!

  session[:player_hand] = []
  session[:dealer_hand] = []
  2.times do
    session[:player_hand] << session[:deck].pop
    session[:dealer_hand] << session[:deck].pop
  end

  if calculate_total(session[:player_hand]) == 21
    session[:player_money] += session[:bet_amount] * 2
    winner!("#{session[:player_name]} has blackjack! #{session[:player_name]} now has $#{session[:player_money]}.")
  end
  erb :game
end

post '/hit' do
  session[:player_hand] << session[:deck].pop
  if calculate_total(session[:player_hand]) > 21
    session[:player_money] -= session[:bet_amount]
    loser!("#{session[:player_name]} busted at #{calculate_total(session[:player_hand])}. #{session[:player_name]} now has $#{session[:player_money]}.")
  elsif calculate_total(session[:player_hand]) == 21
    session[:player_money] += session[:bet_amount] * 2
    winner!("#{session[:player_name]} has blackjack! #{session[:player_name]} now has $#{session[:player_money]}.")
  end
  erb :game, layout: false
end

post '/stay' do
  redirect '/dealer'
end

get '/dealer' do
  if calculate_total(session[:dealer_hand]) == 21
    session[:player_money] -= session[:bet_amount]
    loser!("Dealer has blackjack! #{session[:player_name]} now has $#{session[:player_money]}.")
  elsif calculate_total(session[:dealer_hand]) > 21
    session[:player_money] += session[:bet_amount]
    winner!("Dealer busted at #{calculate_total(session[:dealer_hand])}. #{session[:player_name]} now has $#{session[:player_money]}.")
  elsif calculate_total(session[:dealer_hand]) >= 17
    redirect '/dealer/stay'
  else
    @dealer_turn = true
  end
  @player_turn = false
  erb :game, layout: false
end

post '/dealer/hit' do
  session[:dealer_hand] << session[:deck].pop
  redirect '/dealer'
end

get '/dealer/stay' do
  if calculate_total(session[:player_hand]) > calculate_total(session[:dealer_hand])
    session[:player_money] += session[:bet_amount]
    winner!("#{session[:player_name]} has #{calculate_total(session[:player_hand])} and dealer has #{calculate_total(session[:dealer_hand])}. #{session[:player_name]} now has $#{session[:player_money]}.")
  elsif calculate_total(session[:player_hand]) < calculate_total(session[:dealer_hand])
    session[:player_money] -= session[:bet_amount]
    loser!("#{session[:player_name]} has #{calculate_total(session[:player_hand])} and dealer has #{calculate_total(session[:dealer_hand])}. #{session[:player_name]} now has $#{session[:player_money]}.")
  else
    tie!("#{session[:player_name]} now has $#{session[:player_money]}.")
  end
  erb :game, layout: false  
end

get '/game_over' do
  erb :game_over
end