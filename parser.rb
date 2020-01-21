#!/usr/bin/env ruby
require './support'
require 'rubygems'
require 'engtagger'
require 'pragmatic_segmenter'
require 'sinatra'
require 'sinatra/cors'
require 'pry'
require 'json'
# require 'awesome_print'

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
  # binding.pry
  text = text.force_encoding('UTF-8')
  text.gsub!("\xE2\x80\x8C", '')
  text.gsub!("\u00A0", ' ')
  puts text
  text
end

post '/' do
  text = format_text(request.body.string)
  # puts "text: " + text
  response.header.update({"Content-Type" => 'text/json', "X-Content-Type-Options" => 'nosniff'})
  puts passive_voice(text).to_json
  passive_voice(text).to_json
end
