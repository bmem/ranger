class CreateCreditSchemes < ActiveRecord::Migration
  def change
    create_table :credit_schemes do |t|
      t.references :event, :null => false
      t.string :name, :null => false
      t.decimal :base_hourly_rate, :null => false
      t.text :description

      t.timestamps
    end
    add_index :credit_schemes, :event_id

    create_table :credit_schemes_positions do |t|
      t.references :credit_scheme
      t.references :position
    end
    add_index :credit_schemes_positions, [:credit_scheme_id, :position_id], :name => 'credit_schemes_positions_on_scheme_position', :unique => true
    add_index :credit_schemes_positions, [:position_id, :credit_scheme_id], :name => 'credit_schemes_positions_on_position_scheme'
  end
end
