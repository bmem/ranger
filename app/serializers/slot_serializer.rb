class SlotSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :shift_id, :min_people, :max_people, :attendees_count,
    :credit_value, :credit_value_formatted

  has_one :position
end
