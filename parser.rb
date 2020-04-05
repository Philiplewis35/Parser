require './support'
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

def get_passive_sentences(text)
  sentences = PragmaticSegmenter::Segmenter.new(text: text).segment
  passive_sentences = []
  sentences.map do |sentence|
    passive_sentences << sentence if EngTagger.new.add_tags(sentence) =~ passive_regex
  end
  passive_sentences
end

def format_response(passive_sentences, results = [])
  passive_sentences.map do |passive_sentence |
    results << {
                phrase: pluck_passive(passive_sentence),
                explanation: 'This phrase may be written in passive voice.',
                suggested_replacement: 'Consider revising'
              }
  end
  results
end

post '/analyse' do
  return [].to_json unless params[:text]
  text = JSON.parse(params[:text].to_json)
  format_response(get_passive_sentences(text)).to_json
end

get '/name' do
  'Passive voice detector'
end

get '/description' do
  'Detects passive voice'
end
