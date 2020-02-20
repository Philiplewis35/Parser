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

def get_passive_sentences(text)
  sentences = PragmaticSegmenter::Segmenter.new(text: text).segment
  passive_sentences = []
  sentences.map do |sentence|
    passive_sentences << sentence if passive?(sentence) && !passive_exception?(sentence)
  end
  passive_sentences
end

def passive?(phrase)
  phrase = EngTagger.new.add_tags(phrase)
  matches = passive_voice_regexes.map { |regex| phrase =~ regex }.compact.any?
end

def format_response(passive_sentences, results = [])
  passive_sentences.map do |passive_sentence |
    results << {
                phrase: pluck_passive(passive_sentence),
                explanation: 'This phrase is written in passive voice.',
                suggested_replacements: []
              }
  end
  results
end

post '/analyse' do
  text = JSON.parse(params[:text].to_json)
  format_response(get_passive_sentences(text)).to_json
end

get '/name' do
  'Passive voice detector'
end

get '/description' do
  'Detects passive voice'
end
