module TimeHelper
  def distance_of_time_hours_minutes(start_time, end_time)
    end_time ||= Time.now
    seconds = end_time.to_time - start_time.to_time
    hm = hours_minutes(seconds)
    format_hours_minutes(hm[0], hm[1], false)
  end

  def format_hours_minutes(hours, minutes, zero_pad_hours=true)
    format(zero_pad_hours ? '%02d:%02d' : '%d:%02d', hours, minutes)
  end

  def format_seconds_as_hours_minutes(seconds)
    hm = hours_minutes(seconds)
    format_hours_minutes(hm[0], hm[1], false)
  end

  # Computes [hours, minutes] from a number of seconds.
  def hours_minutes(seconds)
    # convert seconds to minutes, divmod to get hours and remainder
    seconds.fdiv(60).round.divmod(60)
  end

  def relative_date_tag(date_or_time, options = {})
    options = {class: ''}.merge options
    classes = options[:class].split
    if date_or_time.blank?
      classes << 'date-empty'
      options[:class] = classes.join(' ')
      content_tag :span, '', options
    else
      classes << 'date'
      classes << 'time' if date_or_time.acts_like? :time
      if date_or_time.past?
        classes << 'past'
        suffix = 'ago'
      else
        classes << 'future'
        prefix = 'in'
      end
      options[:title] = l date_or_time, format: :long
      options[:class] = classes.join(' ')
      options[:datetime] = date_or_time.to_s
      difference = (Time.zone.now - date_or_time).abs
      text = if difference < 1.month
               "#{prefix} #{time_ago_in_words date_or_time} #{suffix}"
             elsif difference < 1.year
               l date_or_time.to_date, format: :short
             else
               l date_or_time.to_date, format: :default
             end
      content_tag :time, text, options
    end
  end
end
