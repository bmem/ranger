class Authorization < ActiveRecord::Base
  belongs_to :event
  belongs_to :involvement
  belongs_to :user
  attr_accessible :type, :involvement_id

  validates :type, presence: true
  validates :event_id, presence: true
  validates :involvement_id, presence: true
  validates :involvement_id, uniqueness: {scope: [:type, :event_id], message: 'is already authorized'}

  self.per_page = 100

  def self.inherited(child)
    child.instance_eval do
      def model_name
        Authorization.model_name
      end
    end
    super
  end

  def self.human_types
    Hash[descendants.map {|c| [c.to_s, c.to_s.underscore.humanize]}]
  end

  def parent_records
    [event]
  end

  def human_type
    (type.presence || 'Authorization').underscore.humanize
  end

  def to_title
    "#{involvement} #{human_type}"
  end
end
