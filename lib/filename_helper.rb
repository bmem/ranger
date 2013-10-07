module FilenameHelper
  # Allow number, letter, combining mark, space, dash, underscore, period
  INVALID_CHARACTERS = /[^[[:word:]].-]+/
  # TODO figure out why /[^\p{N}\p{L}\p{M}\p{Zs}\p{Pd}\p{Pc}.]/ doesn't parse

  def self.append_features(base)
    super
    base.extend ClassMethods
  end

  def self.normalize(filename, options = {})
    options = options.reverse_merge replacement: '_', default_name: 'untitled'
    filename = filename.gsub(INVALID_CHARACTERS, options[:replacement])
    filename = options[:default_name] if filename.blank?
    options[:extension].try do |ext|
      filename += ext unless filename.downcase.end_with? ext.downcase
    end
    filename
  end

  module ClassMethods
    def normalize_filename(filename, options = Hash.new)
      FilenameHelper.normalize(filename, options)
    end
  end
end
