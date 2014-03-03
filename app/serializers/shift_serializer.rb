class ShiftSerializer < ActiveModel::Serializer
  include TimeHelper

  attributes :id, :event_id, :slot_ids, :name, :description,
    :duration_seconds, :duration_formatted,
    :start_time, :end_time, :start_time_formatted, :end_time_formatted
  has_many :slots

  def duration_formatted
    format_seconds_as_hours_minutes duration_seconds
  end

  def start_time_formatted
    I18n.localize start_time, format: :short
  end

  def end_time_formatted
    I18n.localize end_time, format: :short
  end
end
