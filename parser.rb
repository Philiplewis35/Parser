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
  /.*NN.*VB.*IN.*NN.*/, # The leters were written by james
  /.*NN.*VBN.*VBN.*/, # letters have been written
  /.*NN.*(VBZ|VBD).*VBN[^NN]*/] # is sold/were made/was robbed

  phrase = EngTagger.new.get_readable(phrase)
  matches = passive_voice_regexes.map do |regex|
    match = regex.match(phrase)
    match[0] == phrase if match
  end
  matches.include?(true)
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
