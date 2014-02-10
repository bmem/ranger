class Art < ActiveRecord::Base
  audited

  has_and_belongs_to_many :involvements
  has_and_belongs_to_many :trainings

  attr_accessible :description, :name, :prerequisite

  validates :name, :presence => true, :uniqueness => true

  default_scope order('LOWER(name) ASC')
end
