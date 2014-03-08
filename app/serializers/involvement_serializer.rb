class InvolvementSerializer < ActiveModel::Serializer
  embed :ids

  # TODO detail attributes
  attributes :id, :name, :barcode, :involvement_status, :personnel_status,
    :on_site, :position_ids

  has_one :person
  has_many :positions
end
