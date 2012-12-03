##
# A validator which ensures a date falls within some reasonable range.
#
# = Configuration ptions
# * <tt>:allow_past</tt> - Whether to allow dates in the past (default: true)
# * <tt>:allow_future</tt> - Whether to allow dates in the future
#   (default: true)
# * <tt>:min_year</tt> - The earliest allowable year (default: 1900)
# * <tt>:max_year</tt> - The latest allowable year
#   (default: 50 years from now)
class ReasonableDateValidator < ActiveModel::EachValidator
  def initialize(options={})
    super
    @allow_past = option(options, :allow_past, true)
    @allow_future = option(options, :allow_future, true)
    @min_year = option(options, :min_year, 1900)
    @max_year = option(options, :max_year, Date.current.year + 50)
  end

  def validate_each(record, attribute, value)
    if value.respond_to? :to_date then
      d = value.to_date
      if d.past? then
        record.errors[attribute] <<
          "must not be in the past" unless @allow_past
      elsif d.future? then
        record.errors[attribute] <<
          "must not be in the future" unless @allow_future
      end
      record.errors[attribute] << "must be more recent" if d.year < @min_year
      record.errors[attribute] << "must be more recent" if d.year > @max_year
    end
  end

  private
  def option(options, key, default)
    options.has_key?(key) ? options[key] : default
  end
end
