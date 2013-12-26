namespace :clubhouse do
  BASEDIR = './lib/secretclubhouse'
  include ActionView::Helpers::DateHelper

  def init
    Dir.glob("#{BASEDIR}/bootstrap.rb") {|file| require file}
    ActsAsIndexed.configuration.disable_auto_indexing = true
    puts "Indexing disabled; when finished run: rake index:rebuild"
  end

  def with_timing(activity = 'activity' &block)
    init
    puts "### Begin #{activity}"
    started = Time.zone.now
    yield
    ended = Time.zone.now
    puts "### #{activity} ran for #{distance_of_time_in_words(started, ended, true)}"
  end

  desc "Convert everything from Secret Clubhouse to BMEM"
  task convert: [:convertmain, :assets, :schedules, :credits, :mentors, :reserved_callsigns, :teams]

  desc "Convert people and more from Secret Clubhouse to BMEM"
  task :convertmain => :environment do
    with_timing 'convert main data' do
      User.first_user_is_admin = false
      errors = []
      SecretClubhouse::Conversion.ensure_events_created

      target_models = [
        ::Position, ::Person, ::Involvement, ::WorkLog, ::Callsign,
        Audited.audit_class
      ]
      # Transaction can speed things up, but with SQLite it will keep the whole
      # transaction sequence in memory which can slow it down or OOM
      ::Person.connection.transaction do
        target_models.each do |model|
          puts "Deleting old #{model} records"
          model.connection.transaction do
            model.destroy_all
          end
        end
      end # transaction
      [SecretClubhouse::Position, SecretClubhouse::Person].each do |from_table|
        errors += SecretClubhouse::Conversion::convert_model(from_table)
      end # convert models each
      errors += SecretClubhouse::Conversion::convert_users
      puts "#{errors.count} errors"
      puts errors.join("\n")
      target_models.each do |model|
        puts "#{model.model_name.human}: #{model.count}"
      end
    end
  end

  desc "Convert mentors"
  task :mentors => :environment do
    with_timing 'convert mentors' do
      errors = []
      target_models = [
        ::Mentorship, ::Mentor
      ]
      ::Mentorship.connection.transaction do
        target_models.each do |model|
          puts "Deleting old #{model} records"
          model.destroy_all
        end
        [SecretClubhouse::PersonMentor].each do |from_table|
          errors += SecretClubhouse::Conversion::convert_model(from_table)
        end # convert models each
      end # transaction
      puts "#{errors.count} errors"
      puts errors.join("\n")
      target_models.each do |model|
        puts "#{model.model_name.human}: #{model.count}"
      end
    end
  end

  desc "Convert assets"
  task :assets => :environment do
    with_timing 'converting assets' do
      model = ::Asset
      errors = []
      model.connection.transaction do
        puts "Deleting old #{model} records"
        model.destroy_all
        errors +=
          SecretClubhouse::Conversion::convert_model(SecretClubhouse::Asset)
      end # transaction
      puts "#{errors.count} errors"
      puts errors.join("\n")
      puts "#{model.model_name.human}: #{model.count}"
    end
  end

  desc "Import credit scheme definitions"
  task :credits => :environment do
    with_timing 'creating credit deltas' do
      schemes_hash = YAML.load(IO.read("#{BASEDIR}/credit_schemes.yml")).group_by {|k,v| v['event']}
      deltas_hash = YAML.load(IO.read("#{BASEDIR}/credit_deltas.yml")).group_by {|k,v| v['credit_scheme']}
      SecretClubhouse::Conversion.create_credits(schemes_hash, deltas_hash)
    end
  end

  desc "Convert shift schedules from Secret Clubhouse to BMEM"
  task :schedules => :environment do
    with_timing 'converting shifts' do
      ::Shift.transaction do
        ::Shift.destroy_all
        SecretClubhouse::Conversion.convert_shifts
      end
    end
  end

  desc "Import reserved callsigns"
  task :reserved_callsigns => :environment do
    require 'csv'
    with_timing 'importing reserved callsigns' do
      ::Callsign.transaction do
        csv = CSV.read "#{BASEDIR}/reserved_callsigns.csv",
          headers: true, header_converters: :symbol
        csv.each do |row|
          Callsign.find_or_create_by_name!(row[:name]) do |callsign|
            puts "Adding reserved callsign #{callsign.name}"
            callsign.status = row[:status]
            callsign.note = row[:note]
          end
        end
      end
    end
  end

  desc "Create teams based on position possession"
  task teams: :environment do
    with_timing 'create teams' do
      ::Team.transaction do
        SecretClubhouse::Conversion.convert_teams
      end
    end
  end
end
