require 'pry'

$sessions = []

class Session
  attr_reader :session_key

  def initialize(session_key)
    @session_key = session_key
    @ignored_text = []
    $sessions << self
  end

  def add_ignored_phrase(phrase)
    @ignored_text << phrase
  end

  def ignored_text
    @ignored_text
  end
end

def get_session(session_key)
  session = $sessions.find { |session| session.session_key == session_key }
  session ||= Session.new(session_key)
end
