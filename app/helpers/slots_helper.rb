module SlotsHelper
  def slot_meter_tag(slot)
    num = slot.attendees_count || 0
    max = slot.max_people > 0 ? slot.max_people : 1000
    min = slot.min_people
    opt = slot.max_people > 0 ? slot.max_people : slot.min_people * 2
    title = "#{num} of #{max} (#{min} min)"
    content_tag 'meter', title,
      {value: num, min: 0, low: min, max: max, optimum: opt, title: title}
  end
end
