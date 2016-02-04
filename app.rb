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

post '/mull/' do
  runner = Mulligan::VariableCountSim.new(1000, params[:ramp].to_i, params[:curve].to_i)
  @stats = runner.results
  erb :output
end