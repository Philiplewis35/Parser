require './support'
require './session'
require 'rubygems'
require 'engtagger'
require 'pragmatic_segmenter'
require 'sinatra'
require 'sinatra/cors'
require 'pry'
require 'json'

set :allow_origin, '*'
set :allow_methods, "POST"
set :allow_headers, "Content-Length, Content-Type, X-Content-Type-Options"
set :expose_headers, "Content-Length, Content-Type, X-Content-Type-Options"
set :port, 5678

def get_the(text)
  sentences = PragmaticSegmenter::Segmenter.new(text: text).segment
  sentences_arr = []
  sentences.map do |sentence|
    sentences_arr << sentence if sentence.include? 'the'
  end
  sentences_arr
end

def format_response(sentences, results = [])
  sentences.map do |sentence|
    results << {
                phrase: 'the',
                explanation: 'This is the word "the"',
                suggested_replacements: []
              }
  end
  results
end

post '/analyse' do
  text = JSON.parse(params[:text].to_json)
  format_response(get_the(text)).to_json
end

get '/name' do
  'The detector'
end

get '/description' do
  'Detects the'
end
