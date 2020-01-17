def passive_voice_regexes
  [ /(<vb(n|d)>\w*?<\/vb(n|d)>|<jj>\w*?<\/jj>)( <r\w*?>\w*?<\/r\w*?>)*? <in>by<\/in>( <jj>\w*?<\/jj>| <prp\w*>\w*?<\/prp\w*>| <det>\w*?<\/det>| <in>\w*?<\/in>)*? (<nn\w*?>\w*?<\/nn\w*?>|<prp\w*>\w*?<\/prp\w*>)/,
    /by<\/in>( <(jj|rb)>\w*?<\/(jj|rb>))* <wp>what/, # by what was in the evelope
    /<in>by<\/in> <prp>it<\/prp>/, # overwhelmed by it
    /<nn\w*?>\w*?<\/nn\w*>( <(jj|rb)>\w*?<\/(jj|rb>))* <vbd>(was|were)<\/vbd>( <(jj|rb)>\w*?<\/(jj|rb>))* <vbn>\w*?<\/vbn>/ # were written, was robbed
  ]
end

def passive_exceptions_regex
  [/prp> <in>by</, # helped himself by buying a car
    /by<\/in> <det>the<\/det> <nn\w*?>.*<\/nn\w*?> <in>\w*?<\/in>( <det>the<\/det>)*( <prp\w*?>\w*?<\/prp.\w*?>)* <nn.\w*?>\w*?<\/nn\w*?>/,
    # by the side of the road, by the look on his face
    /by<\/in> <vbg>/, # avoided the dog by jumping over it
    /vbg> <in>by/, # he was talking by the table
    /by<\/in> <vbg>/, # he repaired the car by caling a mechanic
    /\/cd> <in>by<\/in>/, # one by one
    /<in>by<\/in> <cd>/, # late by 15 minutes
    /<\/nn\w*?> <in>by/] # he repaired the car by caling a mechanic
end

def passive_exceptions
  exceptions = ['by way of', 'by,', 'came in by', 'by a long', 'by a wide', 'by a significant', 'by that time']
  exceptions << append('by', %w(ear now far next last morning lunch lunchtime dawn dusk day night then tomorrow yesterday))
  exceptions << append('by the', %w(way arm hand hands arms time day hour year minute second))
  exceptions << prepend('by', %w(and stood stop drop followed it close came stopped dropped))
  exceptions.flatten
end

def passive_exception?(phrase)
  phrase = pluck_passive(phrase)
  exception_found = passive_exceptions_regex.map { |regex| (EngTagger.new.add_tags(phrase) =~ regex) ? true : false }
  exception_found << passive_exceptions.map { |exception| phrase.include?(exception) }
  exception_found.flatten.include?(true)
end

def append(phrase, to_append)
  to_append.map { |appendage| phrase + ' ' + appendage }
end

def prepend(phrase, to_prepend)
  to_prepend.map { |prependage| prependage + ' ' + phrase }
end

def pluck_passive(phrase)
  phrase = EngTagger.new.add_tags(phrase)
  isolated_passive = passive_voice_regexes.map do |regex|
    if phrase =~ regex
      phrase = remove_puncutation_space(phrase)
      phrase.match(regex)[0].gsub(/<\/?[^>]+(>|$)/, "")
    end
  end
  isolated_passive.compact.first
end

def remove_puncutation_space(phrase)
  punctuation = %w(pp ppc ppd ppl prr pps lrb rrb)
  punctuation.each { |p_mark| phrase.gsub!(/> <#{p_mark}>/, "><#{p_mark}>") }
  phrase
end
