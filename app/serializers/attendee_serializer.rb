class AttendeeSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :status

  has_one :slot
  has_one :shift
  has_one :involvement
  has_one :position
end
