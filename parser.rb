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

$index = 0

def passive_voice(text)
  passive_sentences = passive_sentences(text)
  active_suggestions = active_suggestions(passive_sentences)
end

def passive_sentence?(phrase)
  phrase = EngTagger.new.add_tags(phrase)
  matches = passive_voice_regexes.map { |regex| phrase =~ regex }.compact.any?
end

def passive_sentences(text)
  sentences = PragmaticSegmenter::Segmenter.new(text: text).segment
  passive_sentences = []
  sentences.map do |sentence|
    passive_sentences << sentence if passive_sentence?(sentence) && !passive_exception?(sentence)
  end
  passive_sentences
end

def active_suggestions(passive_sentences)
  results = []
  passive_sentences.map do |passive_sentence |
    $index += 1
    results << {id: $index, phrase: pluck_passive(passive_sentence), explanation: convert_to_active_voice(passive_sentence), suggested_replacements: []}
  end
  results
end

def convert_to_active_voice(passive_sentence)
  'This sentence contains the use of passive voice'
end

def format_text(text)
  text = text.force_encoding('UTF-8')
  text.gsub!("\xE2\x80\x8C", '')
  text.gsub!("\u00A0", ' ')
  text
end

post '/' do
  text = format_text(params[:text])
  response.header.update({"Content-Type" => 'text/json', "X-Content-Type-Options" => 'nosniff'})
  passive_voice(text).to_json
end

# post '/ignore' do
#   text = format_text(params[:text])
#   ignored_phrase = pluck_passive(text)
#   session = get_session(params[:session_key])
#   session.add_ignored_phrase(ignored_phrase)
#   (ignored_phrase + ': ignored').to_json
# end

# get '/explainer' do
#   @phrase = 'foobar'
#   erb :explainer
# end

get '/name' do
  'Passive voice detector'
end

get '/description' do
  'Detects passive voice'
end
