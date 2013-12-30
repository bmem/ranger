class Report < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  attr_accessible :name, :note

  serialize :report_object, Reporting::Report
  serialize :readable_parameters # Hash

  audited except: [:report_object, :readable_parameters]

  validates_presence_of :user, :name, :report_object

  default_scope order('created_at DESC')
end
