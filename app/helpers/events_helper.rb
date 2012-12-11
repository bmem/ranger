module EventsHelper
  def report_csv
    FasterCSV.generate do |csv|
      csv << @cols
      @rows.each {|row| csv << row}
    end
  end
end
