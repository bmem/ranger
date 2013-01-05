class Art < ActiveRecord::Base
  has_and_belongs_to_many :participants
  has_and_belongs_to_many :trainings

  attr_accessible :description, :name, :prerequisite

  validates :name, :presence => true, :uniqueness => true

  default_scope order('LOWER(name) ASC')
end
