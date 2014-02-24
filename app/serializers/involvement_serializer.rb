class InvolvementSerializer < ActiveModel::Serializer
  # TODO detail attributes
  attributes :id, :name, :barcode, :involvement_status, :personnel_status,
    :on_site, :person_id, :position_ids, :slot_ids

  has_many :positions
  has_many :slots
end
