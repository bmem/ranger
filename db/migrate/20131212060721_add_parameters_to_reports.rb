class AddParametersToReports < ActiveRecord::Migration
  def change
    add_column :reports, :readable_parameters, :text
  end
end
