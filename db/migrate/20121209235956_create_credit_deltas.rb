class CreateCreditDeltas < ActiveRecord::Migration
  def change
    create_table :credit_deltas do |t|
      t.references :credit_scheme, :null => false
      t.string :name
      t.decimal :hourly_rate, :null => false
      t.datetime :start_time, :null => false
      t.datetime :end_time, :null => false

      t.timestamps
    end
    add_index :credit_deltas, :credit_scheme_id
  end
end
