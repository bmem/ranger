class AuthorizationSerializer < ActiveModel::Serializer
  attributes :id, :type
  has_one :event
  has_one :involvement
  has_one :user
end
