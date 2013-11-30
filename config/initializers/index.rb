require 'string_extensions'

ActsAsIndexed.configure do |config|
  config.case_sensitive = false
  config.min_word_size = 1
end
