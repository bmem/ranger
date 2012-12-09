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
