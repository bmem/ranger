namespace :clubhouse do
  BASEDIR = './lib/secretclubhouse'
  include ActionView::Helpers::DateHelper

  def init
    Dir.glob("#{BASEDIR}/bootstrap.rb") {|file| require file}
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
  task :convert => [:convertmain, :assets, :schedules, :credits]

  desc "Convert people and more from Secret Clubhouse to BMEM"
  task :convertmain => :environment do
    with_timing 'convert main data' do
      User.first_user_is_admin = false
      errors = []
      SecretClubhouse::Conversion.ensure_events_created

      target_models = [
        ::Position, ::Person, ::Involvement, ::User, ::WorkLog
      ]
      ::Person.connection.transaction do
        target_models.each do |model|
          puts "Deleting old #{model} records"
          model.destroy_all
        end
        [
          SecretClubhouse::Position,
          SecretClubhouse::Person,
        ].each do |from_table|
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
end
