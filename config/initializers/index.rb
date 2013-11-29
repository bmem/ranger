class String
  def to_tokens
    s = self.to_ascii.squish
    if s.blank?
      []
    else
      tokens = s.split(/\s+/)
      # add each component of CamelCase names
      tokens += tokens.grep(/[a-z][A-Z]/).map do |x|
        x.underscore.gsub(/[\W_]+/, ' ')
      end
    end
  end
end

ActsAsIndexed.configure do |config|
  config.case_sensitive = false
  config.min_word_size = 1
end
