def passive_regex
  /((<vbd>\w*?<\/vbd>)|(<vbp>are<\/vbp>)|(<vbz>is<\/vbz>)|(<vb>be<\/vb>)|(<vbg>being<\/vbg>))( <(jj|rb)>\w*?<\/(jj|rb>))* <vbn>\w*?<\/vbn>/
end

def pluck_passive(phrase)
  phrase = EngTagger.new.add_tags(phrase)
  phrase = remove_puncutation_space(phrase)
  phrase = phrase.match(passive_regex)
  phrase[0].gsub!(/<\/?[^>]+(>|$)/, "") if phrase
end

def remove_puncutation_space(phrase)
  punctuation = %w(pp ppc ppd ppl prr pps lrb rrb)
  punctuation.each { |p_mark| phrase.gsub!(/> <#{p_mark}>/, "><#{p_mark}>") }
  phrase
end
