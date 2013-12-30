class Position < ActiveRecord::Base
  include FriendlyId
  friendly_id :name, use: :slugged

  audited

  attr_accessible :name, :team_id, :description, :new_user_eligible, :all_team_members_eligible

  belongs_to :team
  has_and_belongs_to_many :people
  has_many :involvements, :through => :people
  has_many :work_logs

  validates :name, :presence => true
  validates :slug, :presence => true

  default_scope { order('LOWER(name)') }
  scope :teamless, -> { where(team_id: nil) }

  def <=>(x)
    name.downcase <=> x.name.downcase
  end

  def should_generate_new_friendly_id?
    # Leave slugs from fixtures or initial creation in place
    slug.blank?
  end
end
