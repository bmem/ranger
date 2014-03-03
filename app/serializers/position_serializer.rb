class PositionSerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :description, :team_id,
    :new_user_eligible, :all_team_members_eligible
end
