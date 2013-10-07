require 'reporting'

module Reporting
  class KeyValueReportTest < Test::Unit::TestCase
    def test_basic_csv
      report = KeyValueReport.new key_order: [:fruit, :color, :count],
        key_labels: {color: 'Hue', fruit: 'Fruit', count: '# Fruits'},
        csv_options: {row_sep: "\n"}
      report.add_entry fruit: 'Apple', color: 'Red & Green', count: 12
      report.add_entry color: 'Yellow', count: 6, fruit: 'Banana'
      report.add_entry count: 42, fruit: 'Cherry', color: 'Red'
      report.add_entry fruit: 'Durian', count: 0
      report.add_summary fruit: 'Total', count: 60
      csv = report.to_csv

      desired_output = [
        'Fruit,Hue,# Fruits',
        'Apple,Red & Green,12',
        'Banana,Yellow,6',
        'Cherry,Red,42',
        'Durian,,0',
        'Total,,60'
      ].join("\n") + "\n"
      assert_equal desired_output, csv
    end
  end
end
