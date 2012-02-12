# This migration comes from schedule (originally 20111225224424)
class CreateSchedulePeople < ActiveRecord::Migration
  def change
    create_table :schedule_people do |t|
      t.string :name, :null => false

      t.timestamps
    end
  end
end
