class Position < ActiveRecord::Base
  belongs_to :team
  has_and_belongs_to_many :people
  has_many :involvements, :through => :people
  has_many :work_logs

  validates :name, :presence => true

  default_scope { order('LOWER(name)') }
  scope :teamless, -> { where(team_id: nil) }

  def <=>(x)
    name.downcase <=> x.name.downcase
  end
end
