# :decimal default in MySQL is precision 10 scale 0. Make credits use scale 2.
class CreditDecimalScale < ActiveRecord::Migration
  def up
    change_column :credit_schemes, :base_hourly_rate, :decimal, :precision => 10, :scale => 2
    change_column :credit_deltas, :hourly_rate, :decimal, :precision => 10, :scale => 2
  end

  def down
    change_column :credit_schemes, :base_hourly_rate, :decimal
    change_column :credit_deltas, :hourly_rate, :decimal
  end
end
