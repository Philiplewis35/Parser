#!/usr/bin/env ruby
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
$ignored_text = []

def passive_voice(text, session_key)
  passive_sentences = passive_sentences(text, session_key)
  active_suggestions = active_suggestions(passive_sentences)
end

def passive_sentence?(phrase)
  phrase = EngTagger.new.add_tags(phrase)
  matches = passive_voice_regexes.map { |regex| phrase =~ regex }.compact.any?
end

def passive_sentences(text, session_key)
  sentences = PragmaticSegmenter::Segmenter.new(text: text).segment
  passive_sentences = []
  sentences.map do |sentence|
    passive_sentences << sentence if passive_sentence?(sentence) && !passive_exception?(sentence) && !ignored?(sentence, session_key)
  end
  passive_sentences
end

def ignored?(sentence, session_key)
  session = get_session(session_key)
  session.ignored_text.include? pluck_passive(sentence)
end

def active_suggestions(passive_sentences)
  results = {}
  passive_sentences.map do |passive_sentence |
    $index += 1
    results[pluck_passive(passive_sentence)] = [$index, convert_to_active_voice(passive_sentence)]
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
  passive_voice(text, params[:session_key]).to_json
end

post '/ignore' do
  text = format_text(params[:text])
  ignored_phrase = pluck_passive(text)
  session = get_session(params[:session_key])
  session.add_ignored_phrase(ignored_phrase)
  (ignored_phrase + ': ignored').to_json
end
