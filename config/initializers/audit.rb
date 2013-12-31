module Audited
  ChangeStruct = Struct.new :field, :old_value, :new_value
  module Audit
    module ClassMethods
      def with_default_audit_comment(comment, &block)
        saved = Thread.current[:default_audit_comment]
        Thread.current[:default_audit_comment] = comment
        yield
      ensure
        Thread.current[:default_audit_comment] = saved
      end
    end

    def change_structs
      (audited_changes || {}).map do |k, v|
        case action
        when 'create' then new_value = v
        when 'destroy' then old_value = v
        when 'update' then old_value, new_value = v
        else
          logger.warning "Unknown audit action #{action}"
          old_value, new_value = v.is_a?(Array) ? v : [v, v]
        end
        ChangeStruct.new k, old_value, new_value
      end
    end
  end
end
