namespace :clubhouse do
  desc "Convert data from Secret Clubhouse to BMEM"
  task :convert => :environment do
    Dir.glob('lib/secretclubhouse/*') {|file| require file}
    errors = []
    (1992..2012).each do |year|
      puts "Finding event for #{year}"
      ::BurningMan.where(:name => "Burning Man #{year}").first_or_create! do |e|
          e.start_date = Date.new(year, 8, 1)
          e.end_date = Date.new(year, 9, 30)
          e.signup_open = false
          e.description = "#{year} data from the Secret Clubhouse"
          puts "Creating Event #{e}"
      end
    end
    target_models = [::Position, ::Person, ::Involvement, ::WorkLog]
    ::Person.connection.transaction do
      target_models.each {|model| model.delete_all}
      # TODO truncate the join table or do destroy_all
      [SecretClubhouse::Position, SecretClubhouse::Person].each do |from_table|
        human_name = from_table.model_name.human
        puts "Converting #{from_table.count} #{human_name.pluralize}"
        from_table.all.each do |from|
          ident = "#{human_name} #{from.id} (#{from.to_s})"
          puts "Converting #{ident}"
          to = from.to_bmem_model
          to.id = from.id
          unless to.save
            err = "Error converting #{ident}: #{to.errors.full_messages}"
            errors << err
            puts err
          end
        end
      end
    end
    puts "#{errors.count} errors"
    puts errors.join("\n")
    target_models.each do |model|
      puts "#{model.model_name.human}: #{model.count}"
    end
  end
end
