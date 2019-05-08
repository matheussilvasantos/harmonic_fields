class Array
  def to_sentence
    words_connector     = ", "
    two_words_connector = " ou "
    last_word_connector = ", ou "

    case length
    when 0
      ""
    when 1
      self[0].to_s.dup
    when 2
      "#{self[0]}#{two_words_connector}#{self[1]}"
    else
      "#{self[0...-1].join(words_connector)}#{last_word_connector}#{self[-1]}"
    end
  end
end
