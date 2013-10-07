module Reporting
  class KeyValueReport < Reporting::Report
    attr_accessor :key_order # Array of key type
    attr_accessor :key_labels # Hash of key type to String
    attr_accessor :entries # Array of Hash
    attr_accessor :summaries # Array of Hash
    attr_accessor :csv_options # Hash of Symbol to ?

    def initialize(options = Hash.new)
      super
      @key_order = options[:key_order] || []
      @key_labels = infer_hash(options[:key_labels] || {})
      @entries = []
      @summaries = []
      @csv_options = options[:csv_options] || {}
    end

    def add_entry(hash)
      entries << hash
      self
    end

    def add_summary(hash)
      summaries << hash
      self
    end

    def to_csv
      CSV.generate(@csv_options) do |csv|
        csv << hash_to_array(@key_labels) if @key_labels.length > 0
        @entries.each do |entry|
          csv << hash_to_array(entry)
        end
        @summaries.each do |summary|
          csv << hash_to_array(summary)
        end
      end
    end

    private
    def hash_to_array(hash)
      @key_order.map {|key| hash[key]}
    end

    def infer_hash(hash_or_array)
      return hash_or_array if hash_or_array.respond_to? :keys
      result = {}
      @key_order.each_with_index {|key, i| result[key] = hash_or_array[i]}
      result
    end
  end
end
