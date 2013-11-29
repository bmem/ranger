namespace :index do
  desc 'Rebuild search indecies'
  task rebuild: :environment do
    ActsAsIndexed.configuration.index_file.tap do |dir|
      dir.rmtree if dir.directory?
    end
    [Person, Involvement].each do |klass|
      puts "Rebuilding #{klass} index"
      klass.build_index
    end
  end
end
