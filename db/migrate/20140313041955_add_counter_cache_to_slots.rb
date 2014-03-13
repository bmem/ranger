class AddCounterCacheToSlots < ActiveRecord::Migration
  def change
    add_column :slots, :attendees_count, :integer

    Slot.select(:id).each do |s|
      Slot.reset_counters(s.id, :attendees)
    end
  end
end
