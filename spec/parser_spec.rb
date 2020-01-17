require 'spec_helper'
require './parser.rb'

describe 'parser' do
  it 'should isolate the passive part of a sentence and provide a suggestion' do
    expect(passive_voice('The letters were written by James.')).to eq({'written by James' => [1, "This sentence contains the use of passive voice"]})
  end

  it 'should return an empty hash for a sentence that does not feature passive voice' do
    expect(passive_voice('my name is bob.')).to be {}
  end
end
