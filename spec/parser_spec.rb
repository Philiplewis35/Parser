require 'spec_helper'
require './parser.rb'

require 'rspec'
require 'rack/test'

describe 'parser' do
  include Rack::Test::Methods


  passive_sentences = ['the letters were written by james', 'the bank was robbed', 'she was surprised by the contents of the envelope',
      'the documents are being signed', 'The piece is really enjoyed by the group', 'The house will be cleaned every week',
      'The machines can be used for that purpose', 'The metal beams were corroded by the seawater',
      'The Grand Canyon is visited by many people every year', 'Instructions will be given later today', 'The comet was viewed by the class',
      'reservations are being made']


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

  it 'should identify the use of passive voice' do
    expect(get_passive_sentences(passive_sentences.join('. ')).length).to eq passive_sentences.length
  end

  it 'should respond with a json structure with the correct format' do
    post '/analyse', text: 'The letters were written by James.'
    result = [{:phrase=>"were written", :explanation=>"This phrase may be written in passive voice.", :suggested_replacement => 'Consider revising'}]
    expect(last_response.body).to eq result.to_json
  end

  it "should return a hash for each passive sentence in the text" do
    post '/analyse', text: 'The bank was robbed. The letters were written by James.'
    result = [{:phrase=>"was robbed", :explanation=>"This phrase may be written in passive voice.", :suggested_replacement => 'Consider revising'},
              {:phrase=>"were written", :explanation=>"This phrase may be written in passive voice.", :suggested_replacement => 'Consider revising'}]
    expect(last_response.body).to eq result.to_json
  end

  it 'should return an empty array for a sentence that does not feature passive voice' do
    post '/analyse', text: 'my name is bob.'
    expect(JSON.parse(last_response.body)).to eq []
  end

  it 'should return an empty array upon the text being nil' do
    post '/analyse', text: nil
    expect(JSON.parse(last_response.body)).to eq []
  end

  it 'should return an empty array upon being sent an empty text' do
    post '/analyse', text: ''
    expect(JSON.parse(last_response.body)).to eq []
  end

  it 'should isolate the passive part of a sentence and provide a suggestion' do
    isolated_passive = ['were written', 'was robbed', 'was surprised', 'being signed', 'is really enjoyed',
    'be cleaned', 'be used', 'were corroded', 'is visited', 'be given', 'was viewed', 'being made']
    passive_sentences.map { |sentence| expect(isolated_passive).to include(pluck_passive(sentence))}
  end

  it 'should not misidentify passive sentences' do
    active_voice_sentences = ['He ate 6 cookies', 'giraffes roam the savannah', 'Sue changed the flat tyre',
                              'We are going to watch a film tonight', 'I ran the obstacle course', 'The crew paved the entire road',
                              'I read the book within 2 weeks', 'I will clean the house next week', 'Tom painted the house',
                              'A fire destroyed the forest', 'You can never be too careful', 'Mice can be cute, sometimes.',
                              'Are you okay?', 'That bread is mouldy', 'When was the last match on?']

    expect(get_passive_sentences(active_voice_sentences.join('. '))).to eq []
  end
end
