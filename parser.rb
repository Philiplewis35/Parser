#!/usr/bin/env ruby
require 'rubygems'
require 'engtagger'
require 'pragmatic_segmenter'
require 'sinatra'
require 'sinatra/cors'
require 'pry'

set :allow_origin, '*'
set :allow_methods, "POST"
set :allow_headers, "Content-Length, Content-Type, X-Content-Type-Options"
set :expose_headers, "Content-Length, Content-Type, X-Content-Type-Options"

def passive_voice(text)
  passive_sentences = passive_sentences(text)
  active_suggestions = active_suggestions(passive_sentences)
end

def passive_sentence?(phrase)
  passive_voice_regexes = [
    /<in>by<\/in>/,
    /<vbd>were<\/vbd> <vbn>/,
    /<vb>be<\/vb> <vbn>/ # past tense verb
  ]
  phrase = EngTagger.new.add_tags(phrase)
  matches = passive_voice_regexes.map { |regex| phrase =~ regex }.compact.any?
end

def passive_sentences(text)
  sentences = PragmaticSegmenter::Segmenter.new(text: text).segment
  passive_sentences = []
  sentences.map do |sentence|
    passive_sentences << sentence if passive_sentence?(sentence)
  end
  passive_sentences
end

def active_suggestions(passive_sentences)
  results = {}
  passive_sentences.map.with_index(1) do |passive_sentence, index|
    results[passive_sentence] = [index, convert_to_active_voice(passive_sentence)]
  end
  results
end

# TODO: Actuallt decide if this is neccesarry
def convert_to_active_voice(passive_sentence)
  'This is in passive voice'
end

post '/' do
  text = request.body.string
  text.gsub!(/[^\x00-\x7F]/, " ").gsub!(/\s+/, ' ') # improve this
  response.header.update({"Content-Type" => 'text/json', "X-Content-Type-Options" => 'nosniff'})
  passive_voice(text).to_json
end

get '/' do
  "Hello World"
end
