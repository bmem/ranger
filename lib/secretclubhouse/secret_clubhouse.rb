module SecretClubhouse
  class Conversion
    def self.convert_model(from_model)
      errors = []
      human_name = from_model.model_name.human
      puts "Converting #{from_model.count} #{human_name.pluralize}"
      from_model.all.each do |from|
        unless from.class == PersonMentor and from.person_id == 710 # TODO remove this data hack
        ident = "#{human_name} #{from.id} (#{from.to_s})"
        puts "Converting #{ident}"
        to = from.to_bmem_model
        to.id = from.id
        unless to.save
          err =
            "Error converting #{ident}: #{to.errors.full_messages.to_sentence}"
          errors << err
          puts err
        end
        end # TODO remove hack
      end # from_model.all
      errors
    end

    def self.ensure_events_created
      (1992..2013).each do |year|
        puts "Finding events for #{year}"
        bm = ::BurningMan.where(slug: "burning-man-#{year}").first_or_create! do |e|
          e.name = "Burning Man #{year}"
          e.start_date = Date.new(year, 8, 1)
          e.end_date = Date.new(year, 9, 30)
          e.signup_open = false
          e.description = "#{year} event data from the Secret Clubhouse"
          puts "Creating Event #{e.name}"
        end
        if year >= 2008 # first year with saved shifts
          ::TrainingSeason.where(slug: "training-season-#{year}").first_or_create! do |e|
            e.name = "Training Season #{year}"
            e.start_date = Date.new(year, 4, 1)
            e.end_date = Date.new(year, 9, 1)
            e.signup_open = false
            e.description = "#{year} training data from the Secret Clubhouse"
            e.linked_event = bm
            puts "Creating Event #{e.name}"
          end
        end # if year
      end # each year
    end # ensure_events_created

    def self.create_credits(schemes_hash, deltas_hash)
      ::CreditScheme.transaction do
        ::CreditScheme.destroy_all
        schemes_hash.each do |eid, schemes|
          puts "Adding credit schemes to #{eid}"
          e = ::Event.find_by_slug(eid)
          if e.credit_schemes.empty?
            schemes.each do |s_key, s_attrs|
              position_names = s_attrs.delete 'position_names'
              positions = ::Position.find_all_by_slug(position_names)
              raise "Missing positions in #{position_names} for #{s_key}" unless position_names.count == positions.count
              s_attrs.delete 'event'
              puts "Adding scheme #{s_attrs['name']} to #{e.name}"
              scheme = e.credit_schemes.build s_attrs
              scheme.position_ids = positions.map &:id
              deltas_hash[s_key].try do |deltas|
                deltas.each do |d_key, d_attrs|
                  d_attrs.delete 'credit_scheme'
                  puts "Adding delta #{d_attrs['name']} to #{s_attrs['name']}"
                  delta = scheme.credit_deltas.build d_attrs
                end
              end
            e.save!
            end # schemes
          end # if empty
        end # schemes_hash
      end # transaction
    end # create_credits

    def self.convert_shifts
      (2008..2013).each do |year|
        ts = ::TrainingSeason.find("training-season-#{year}")
        puts "Creating shifts for #{ts}"
        training_slots = Slot.with_position(Position::TRAINING).in_year(year)
        training_slots.each do |t|
          puts "Converting #{t}"
          t.event = ts
          shift = ::Shift.create!(
            :event => ts, :name => t.description, :description => t.url,
            :start_time => t.start_time, :end_time => t.end_time)
          bmem_training_slot = t.to_bmem_model
          bmem_training_slot.shift = shift
          bmem_training_slot.save!
          trainers = Slot.with_position(Position::TRAINER).
            in_year(year).where(:description => t.description)
          if trainers.count > 1
            raise "Too mainy Trainer shifts for #{year} #{t.description}"
          end
          if trainers.count == 1
            trainer = trainers.first
            trainer.event = ts
            puts "Converting #{trainer}"
            bmem_trainer_slot = trainer.to_bmem_model
            bmem_trainer_slot.shift = shift
            bmem_trainer_slot.save!
          end
        end # training_slots
        puts "#{ts.shifts.count} shifts and #{ts.slots.count} slots in #{ts}"
      end # each year

      ::BurningMan.all.each do |bm|
        puts "Creating shifts for #{bm} year #{bm.start_date.year}"
        grouped_slots = Slot.in_year(bm.start_date.year).group_by do |s|
          [s.start_time, s.end_time, shift_name(s)]
        end
        grouped_slots.each do |key, slots|
          raise "#{key[0]} - #{key[1]} vs. #{bm.start_date} - #{bm.end_date}" unless key[0].year == bm.start_date.year
          shift = ::Shift.where(:event_id => bm.id, :name => key[2],
            :start_time => key[0], :end_time => key[1]).first_or_create!
          puts "Creating shift #{shift.name} #{shift.start_time}"
          slots.each do |slot|
            unless ::Slot.exists? slot.id # skip training slots
              slot.event = bm
              bmem_slot = slot.to_bmem_model
              bmem_slot.shift = shift
              bmem_slot.save!
            end
          end
          shift.delete unless ::Slot.exists?({:shift_id => shift.id})
        end # grouped_slots
        puts "#{bm.shifts.count} shifts and #{bm.slots.count} slots in #{bm}"
      end # BurningMan
    end # convert_slots

    def self.shift_name(slot)
      if slot.description.blank?
        slot.start_time.strftime('%A')
      else
        slot.description
      end
    end
  end # class Convert
end # module SecretClubhouse
