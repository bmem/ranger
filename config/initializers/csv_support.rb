ActionController::Renderers.add :csv do |csv, options|
  options = options.reverse_merge type: Mime::CSV, disposition: 'attachment'
  content = if csv.respond_to? :to_csv
    csv.to_csv
  elsif csv.respond_to? :each
      CSV.generate do |output|
        csv.each do |row|
          output << row
        end
      end
  else
    csv.to_s
  end
  options[:filename].try do |filename|
    options[:filename] = FilenameHelper.normalize(filename, extension: '.csv')
  end
  send_data content, options
end
