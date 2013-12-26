module SecretClubhouse
  class Conversion
    def self.audited_as_system_user(&block)
      user = ::User.find_or_create_by_id!(0) do |u|
        u.email = 'ranger-tech-ninjas@burningman.com'
        u.disabled = true
        u.disabled_message = 'System robot user; do not log in'
        u.password = (32.chr..126.chr).to_a.sample(16).join
      end
      Audited.audit_class.as_user user, &block
    end

    def self.convert_model(from_model, &convert)
      errors = []
      human_name = from_model.model_name.human
      puts "Converting #{from_model.count} #{human_name.pluralize}"
      audited_as_system_user do
        from_model.all.each do |from|
          ident = "#{human_name} #{from.id} (#{from.to_s})"
          puts "Converting #{ident}"
          if block_given?
            to = yield from
          else
            to = from.to_bmem_model
            to.id = from.id
          end
          to.audit_comment = 'Secret Clubhouse conversion' if to.respond_to? :audit_comment=
          unless to and to.save
            err = "Error converting #{ident}: #{to.errors.full_messages.to_sentence}"
            errors << err
            puts err
          end
        end # from_model.all
      end # audited_as_system_user
      errors
    end

    def self.convert_users
      self.convert_model(User) do |from|
        sc = from.to_bmem_model
        bmem = ::User.where(id: sc.id).first
        # TODO return nil for non-person users like "Temp 10"
        return sc if bmem.nil?
        if sc.email != bmem.email or sc.person_id != bmem.person_id
          puts "Deleting user #{bmem.email} in favor of #{sc.email}"
          bmem.destroy
          return sc
        end
        bmem.disabled = false unless sc.disabled
        bmem.disabled_message = sc.disabled_message if bmem.disabled
        sc.roles.each do |role|
          unless bmem.has_role? role
            puts "Adding #{role} to #{bmem.email}"
            bmem.user_roles.build(role: role.to_s, user_id: bmem.id)
          end
        end
        bmem
      end
    end

    def self.ensure_events_created
      audited_as_system_user do
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
      end # audited_as_system_user
    end # ensure_events_created

    def self.create_credits(schemes_hash, deltas_hash)
      audited_as_system_user do
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
      end # audited_as_system_user
    end # create_credits

    def self.convert_shifts
      audited_as_system_user do
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
            shift = ::Shift.where(event_id: bm.id, name: key[2],
                start_time: key[0], end_time: key[1]).first_or_create! do |s|
              s.description = slots.map {|slot| slot.position.name}.to_sentence
            end
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
      end # audited_as_system_user
    end # convert_slots

    def self.shift_name(slot)
      if slot.description.blank?
        slot.start_time.strftime('%A')
      else
        slot.description
      end
    end

    TeamDef = Struct.new :name, :description, :positions, :manager_positions, :member_positions
    def self.convert_teams
      defs = [
        TeamDef.new('Operations',
                    "General operations shifts that aren't part of a specialized team structure.\nIt's generally unnecessary to add people as members of this group.",
                    %w(dirt gate-opening hot-springs-patrol orange-dot pre-team-dirt-ranger),
                    %w(operations-manager), []),
        TeamDef.new('Training',
                    "Trainers and training.",
                    %w(trainer training),
                    [],
                    %w(trainer)),
        TeamDef.new('Shift Command',
                    "Shift leads operators OODs and friends.",
                    %w(007 ims-training ood operations-manager operator rsc-envoy rsci rsci-fb-counselor shift-lead),
                    %w(operations-manager ood),
                    %w(ood operations-manager rsc-envoy rsci-fb-counselor shift-lead)),
        TeamDef.new('HQ',
                    "Ranger Headquarters.",
                    %w(hq-full-training hq-long hq-refresher-training hq-runner hq-short hq-supervisor hq-trainer hq-window),
                    %w(hq-long hq-supervisor),
                    %w(hq-long hq-short hq-supervisor hq-window)),
        TeamDef.new('Green Dots',
                    "For situations that require more kleenex than duct tape.",
                    %w(green-dot-long green-dot-mentee green-dot-mentor green-dot-ranger green-dot-sanctuary green-dot-short),
                    %w(green-dot-long),
                    nil),
        TeamDef.new('Mentors',
                    "Mentors and alphas.",
                    %w(alpha cheetah cheetah-cub mentor mentor-long mentor-short),
                    %w(mentor-long),
                    %w(cheetah mentor mentor-long mentor-short)),
        TeamDef.new('Intercept',
                    "Vehicle safety and inner-playa rangering.",
                    %w(intercept intercept-dispatch tow-truck-driver),
                    [],
                    %w(intercept tow-truck-driver)),
        TeamDef.new('Fire Safety',
                    "Burn perimeters and art safety",
                    %w(art-safety burn-perimeter sandman special-burn),
                    [],
                    %w(art-safety)),
        TeamDef.new('LEAL',
                    "Law Enforcement Agency Liasons.",
                    %w(leal leal-trainee),
                    [],
                    %w(leal)),
        TeamDef.new('RNR',
                    "Rapid Night Response.",
                    %w(rnr),
                    [],
                    %w(rnr)),
        TeamDef.new('Echelon',
                    "Ranger Support.",
                    %w(echelon-field),
                    [],
                    %w(echelon-field)),
        TeamDef.new('Tech Team',
                    "Making the bits flow and wires hold.",
                    %w(tech-team),
                    [],
                    %w(tech-team)),
        TeamDef.new('Logistics',
                    "Logistics and SITE.",
                    %w(logistics site-setup site-teardown),
                    [],
                    %w(logistics site-setup)),
        TeamDef.new('Council',
                    "Council-related positions.",
                    %w(personnel-manager),
                    %w(personnel-manager),
                    %w(personnel-manager)),
      ]
      audited_as_system_user do
        defs.each do |teamdef|
          puts "Creating team #{teamdef.name}"
          team = ::Team.find_or_create_by_name!(teamdef.name) do |t|
            t.description = teamdef.description
          end
          team.positions = ::Position.where(slug: teamdef.positions)
          (teamdef.manager_positions || teamdef.positions).try do |pos|
            team.manager_ids = pos.map {|p| ::Position.find(p).person_ids}.flatten.uniq if pos.any?
          end
          (teamdef.member_positions || teamdef.positions).try do |pos|
            team.member_ids = pos.map {|p| ::Position.find(p).person_ids}.flatten.uniq if pos.any?
          end
          team.save!
        end # defs.each
      end # audited_as_system_user
    end # convert_teams
  end # class Conversion
end # module SecretClubhouse
