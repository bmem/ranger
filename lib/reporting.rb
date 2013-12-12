module Reporting
  class Report
    attr_accessor :title # String
    attr_accessor :parameters # Hash

    def initialize(options = Hash.new)
      @title = options[:title]
    end
  end

  ReportResult = Struct.new(:report, :num_results, :readable_parameters)

  require 'reporting/key_value_report'
end
