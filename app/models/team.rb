class Team < ActiveRecord::Base
  include FriendlyId
  friendly_id :name, use: :slugged
  attr_accessible :description, :name, :slug, :manager_ids, :member_ids, :position_ids
  validates_presence_of :name

  has_many :positions
  has_and_belongs_to_many :members,
    join_table: :team_members, class_name: 'Person'
  has_and_belongs_to_many :managers,
    join_table: :team_managers, class_name: 'Person'

  default_scope { order(:name) }
end
