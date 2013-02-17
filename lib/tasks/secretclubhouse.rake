namespace :clubhouse do
  desc "Convert data from Secret Clubhouse to BMEM"
  task :convert => :environment do
    basedir = './lib/secretclubhouse'
    Dir.glob("#{basedir}/*.rb") {|file| require file}
    User.first_user_is_admin = false
    errors = []
    schemes_hash = YAML.load(IO.read("#{basedir}/credit_schemes.yml")).group_by {|k,v| v['event']}
    deltas_hash = YAML.load(IO.read("#{basedir}/credit_deltas.yml")).group_by {|k,v| v['credit_scheme']}
    (1992..2012).each do |year|
      puts "Finding event for #{year}"
      ::BurningMan.where(:name => "Burning Man #{year}").first_or_create! do |e|
        e.start_date = Date.new(year, 8, 1)
        e.end_date = Date.new(year, 9, 30)
        e.signup_open = false
        e.description = "#{year} data from the Secret Clubhouse"
        puts "Creating Event #{e.name}"
      end
    end
    target_models = [::Position, ::Person, ::Involvement, ::User, ::WorkLog]
    ::Person.connection.transaction do
      target_models.each do |model|
        puts "Deleting old #{model} records"
        model.destroy_all
      end
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
      schemes_hash.each do |eid, schemes|
        puts "Adding credit schemes to #{eid.titleize}"
        e = Event.find_by_name(eid.titleize)
        if e.credit_schemes.empty?
          schemes.each do |s_key, s_attrs|
            position_names = s_attrs.delete 'position_names'
            positions = Position.where(:name => position_names)
            raise "Missing positions in #{position_names} for #{s_key}" unless position_names.count == positions.count
            s_attrs.delete 'event'
            puts "Adding scheme #{s_attrs['name']} to #{e.name}"
            scheme = e.credit_schemes.build s_attrs
            scheme.position_ids = positions.map &:id
            deltas_hash[s_key].try do |deltas|
              deltas.each do |d_key, d_attrs|
                d_attrs.delete 'credit_scheme'
                puts "Adding scheme #{d_attrs['name']} to #{s_attrs['name']}"
                delta = scheme.credit_deltas.build d_attrs
              end
            end
          e.save!
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
