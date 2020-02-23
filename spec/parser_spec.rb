require 'spec_helper'
require './parser.rb'

require 'rspec'
require 'rack/test'

describe 'parser' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "returns the service title" do
    get '/name'
    expect(last_response.body).to eq('Passive voice detector')
  end

  it 'returns the service description' do
    get '/description'
    expect(last_response.body).to eq('Detects passive voice')
  end

  it 'should isolate the passive part of a sentence and provide a suggestion' do
    post '/analyse', text: 'The letters were written by James.'
    result = [{:phrase=>"written by James", :explanation=>"This phrase is written in passive voice.", :suggested_replacements=>[]}]
    expect(last_response.body).to eq result.to_json
  end


  it "should return a hash for each passive sentence in the text" do
    post '/analyse', text: 'The bank was robbed. The letters were written by James.'
    expect(JSON.parse(last_response.body).length).to eq 2
  end

  it 'should return an empty hash for a sentence that does not feature passive voice' do
    post '/analyse', text: 'my name is bob.'
    expect(JSON.parse(last_response.body).length).to eq 0
  end

  it 'should identify the use of passive voice' do
    passive = ['the letters were written by james.', 'the bank was robbed', 'she was surprised by the contents of the evelope',
    'he was stunned by her beauty', 'The boy was overwhelmed by it', 'the paper was burnt']

    passive.each do |sentence|
      post '/analyse', text: sentence
      expect(JSON.parse(last_response.body).length).to eq 1
    end
  end

  it 'should not misidentify passive sentences' do
    misnomers = ['she was taken by the arm', 'by the time they reached her.',
      'they could tell by his expression', 'they stopped by to say hello', 'they would reach London by morning',
      'I could have helped, by the way.', 'one by one', 'they overshot by a wide margin', 'they stood by the side of the road']

    misnomers.each do |sentence|
      post '/analyse', text: sentence
      expect(JSON.parse(last_response.body).length).to eq 0
    end
  end

  it 'should return no results when passed an empty string' do
    post '/analyse', text: ''
    expect(JSON.parse(last_response.body).length).to eq 0
  end

  it 'should return no results when text is null' do
    post '/analyse', text: nil
    expect(JSON.parse(last_response.body).length).to eq 0
  end

end
