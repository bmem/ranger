module ApplicationHelper
  def link_to_record(record, *args)
    if @event && record != @event
      link_to record.to_title, polymorphic_path([@event, record], *args)
    else
      link_to record.to_title, record, *args
    end
  end
end
