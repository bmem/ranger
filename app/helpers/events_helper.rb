require 'csv'

module EventsHelper
  def report_csv
    CSV.generate do |csv|
      csv << @cols
      @rows.each {|row| csv << row}
    end
  end
end
