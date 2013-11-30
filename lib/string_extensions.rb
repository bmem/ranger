module Bmem
  module StringExtensions
    module PublicInstanceMethods
      def to_tokens
        s = to_s.to_ascii.squish
        if s.blank?
          []
        else
          tokens = s.gsub(/^\W+|\W+$/, '').split(/\W*\s+\W*/)
          # add each component of CamelCase names
          tokens += tokens.grep(/[a-z][A-Z]|\D\d|\d\D/).map do |x|
            x.underscore.
              gsub(/(\D)(\d)/, '\\1_\\2').
              gsub(/(\d)(\D)/, '\\1_\\2').
              gsub(/[\W_]+/, ' ').
              squish.split
          end.flatten
          # add punctuation-contracted versions
          tokens += tokens.grep(/\W/).map {|x| x.gsub(/\W+/, '')}
          tokens.uniq!
          tokens
        end
      end
    end
  end
end

String.send :include, Bmem::StringExtensions::PublicInstanceMethods
