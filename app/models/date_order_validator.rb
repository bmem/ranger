class DateOrderValidator < ActiveModel::Validator
  def validate(record)
    startdate = record.send(options[:start] || :start_date)
    enddate = record.send(options[:end] || :end_date)
    if startdate && enddate && startdate > enddate
      record.errors[options[:end] || :end_date] << 'Must be after start'
    end
  end
end
