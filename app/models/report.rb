class Report < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  attr_accessible :name, :note

  serialize :report_object, Reporting::Report

  validates_presence_of :user, :name, :report_object
end
