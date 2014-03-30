# ViewModel for listing people who signed up for or attended a slot.
class SlotParticipant
  attr_accessor :slot
  attr_accessor :attendee
  attr_accessor :work_log

  def initialize(*args)
    options = args.extract_options!
    @slot = options[:slot]
    @attendee = options[:attendee]
    @work_log = options[:work_log]
  end

  def involvement
    @involvement ||= (attendee || work_log).involvement
  end

  def name
    involvement.name
  end

  def status
    if work_log
      if work_log.on_duty?
        s = 'on duty'
      else
        s = 'done'
      end
      s += ' (unscheduled)' unless attendee
    else
      s = attendee.status
    end
    s
  end

  def hours_formatted
    work_log.try {|w| w.hours_formatted} or ''
  end

  def credits_formatted
    work_log.try {|w| w.credit_value_formatted} or ''
  end

  def to_s
    name
  end

  def <=>(other)
    name.downcase <=> other.name.downcase
  end
end
