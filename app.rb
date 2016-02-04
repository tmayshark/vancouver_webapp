require 'sinatra'
require_relative './lib/smarter_mull'
include Mulligan

get '/param/:ramp/:curve' do
  runner = Mulligan::VariableCountSim.new(1000, params[:ramp].to_i,params[:curve].to_i)
  @stats= runner.results
  erb :output
end

get '/mull' do
  erb :input_form
end

get '/modal' do
  erb :modal
end

post '/mull/' do
  if params[:ramp].to_i < 0 || params[:ramp].to_i > 25
    erb :error
  elsif
    params[:curve].to_i < 0 || params[:curve].to_i > 50
    erb :error
  else
  runner = Mulligan::VariableCountSim.new(1000, params[:ramp].to_i, params[:curve].to_i)
  @stats = runner.results
  erb :output
  end
end