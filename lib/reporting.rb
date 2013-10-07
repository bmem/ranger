module Reporting
  class Report
    attr_accessor :title # String

    def initialize(options = Hash.new)
      @title = options[:title]
    end
  end

  require 'reporting/key_value_report'
end
