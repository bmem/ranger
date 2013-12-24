module Audited
  ChangeStruct = Struct.new :field, :old_value, :new_value
  module Audit
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
