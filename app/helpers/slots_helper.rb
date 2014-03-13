module SlotsHelper
  def slot_meter_tag(slot)
    num = slot.attendees_count
    max = slot.max_people > 0 ? slot.max_people : 1000
    min = slot.min_people
    opt = slot.max_people > 0 ? slot.max_people : slot.min_people * 2
    tag 'meter', {value: num, min: 0, low: min, max: max, optimum: opt}
  end
end
