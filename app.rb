require 'sinatra'
require_relative './lib/smart_mull'

get '/prefabmull' do
  p = {ramp_count: 15, low_curve_count: 15}
  @runner = Mulligan::IterativeSimulator.new(1000, p)
  output = "<%= @runner.results %>"
  erb output
end

get '/param/:ramp/:curve' do
  p = {ramp_count: params[:ramp].to_i, low_curve_count: params[:curve].to_i}
  @runner = Mulligan::IterativeSimulator.new(10000, p)
  output = "<%= @runner.results %>"
  erb output
end