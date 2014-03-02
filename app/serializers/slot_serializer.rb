class SlotSerializer < ActiveModel::Serializer
  attributes :id, :shift_id, :position_id, :min_people, :max_people,
    :credit_value, :credit_value_formatted
end
