module SecretClubhouse
  module BaseRecord
    def self.included(base)
      base.extend ClassMethods
      base.establish_connection :secretclubhouse
    end

    module ClassMethods
      def target(klass, *attrs)
        @target_class = klass
        @attrs = attrs.collect {|s| s.to_sym}
      end

      def target_class
        @target_class
      end

      def target_attrs
        @attrs
      end
    end

    # Secret Clubhouse tables were declared UTF-8, but PHP connected with
    # ISO-8859-1 (latin1) as its charset.  If a string has non-7-bit-ASCII
    # characters, convert it to latin1 and then reinterpret that as UTF-8.
    def fix_utf8(str)
      if str.split(//).any? {|x| x.ord > 127}
        s = str.encode('ISO-8859-1').force_encoding('UTF-8')
        print "Forcing UTF-8 encoding"
        print " from #{str}"
        print " to #{s}\n"
        s
      else
        str
      end
    end

    def convert_with_attrs(klass, *attrs)
      r = klass.new(Hash[attrs.collect {|a| [a, self.send(a)]}])
      r.id = id # ensure relations remain aligned
      r
    end

    def to_bmem_model
      klass = self.class.target_class
      attrs = self.class.target_attrs
      convert_with_attrs klass, *attrs
    end

    def to_s
      [:display_name, :name, :title].each do |s|
        return self.send(s) if self.respond_to? s
      end
      "#{@convert_class} ##{id}"
    end
  end
end
