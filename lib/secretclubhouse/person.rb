module SecretClubhouse
  class Person < ActiveRecord::Base
    include BaseRecord
    @@rand = Random.new
    self.table_name = 'person'
    target ::Person, :display_name, :full_name, :email, :barcode, :status,
      :position_ids, *::Person::DETAIL_ATTRS

    has_many :timesheets
    has_many :languages
    has_and_belongs_to_many :positions, :join_table => 'person_position'
    has_and_belongs_to_many :roles, :join_table => 'person_role'
    has_and_belongs_to_many :slots, :join_table => 'person_slot'

    def to_bmem_model
      p = super
      profile = p.build_profile full_name: full_name, email: email,
        phone_numbers: phone_numbers, gender: gender, birth_date: birth_date,
        shirt_size: shirt_size, shirt_style: shirt_style
      profile.mailing_address = mailing_address
      profile.id = id # ensure relations remain aligned
      profile.person = p # TODO why is this needed?
      if p.email.blank?
        p.email = callsign.downcase.gsub(/\W+/, '_') + '@noemail.invalid'
      else
        p.email = p.email.strip
      end
      unless EmailHelper::VALID_EMAIL.match p.email
        p.email = p.email.strip.gsub(/[^\w@.-]/, '_').sub(/_+$/, '')
        while p.email.count('@') > 1
          # usually people who list two emails
          # this email won't be good, but will pass validity checks
          p.email = p.email.sub /@/, '_AT_'
        end
        puts "Replacing #{callsign} invalid email #{email} with #{p.email}"
        profile.contact_note ||= "Email converted from #{email}"
      end
      profile.email = p.email
      if shirt_size == 'Unknown'
        profile.shirt_size = nil
      elsif shirt_size =~ /XX+L/
        profile.shirt_size = "#{shirt_size.split(//).count {|c| c == 'X'}}XL"
      end
      if shirt_style =~ /Unknown/
        profile.shirt_style = nil
      end
      languages.map(&:language_name).each do |lang|
        p.language_list << lang.strip.downcase if lang.present?
      end
      # TODO set disabled based on status and user_authorized
      p.build_user :email => p.email, :password => @@rand.bytes(16),
        :disabled => true, :disabled_message => 'Not enabled for test system'
      p.user.id = id # ensure relations remain aligned
      if role_ids.include? 1 # 1 = Admin
        p.user.disabled = false
        p.user.disabled_message = nil
        p.user.user_roles.build :user_id => id, :role => 'admin'
      end
      time_by_year = timesheets.group_by {|t| t.start_time.year}
      # People like Danger Ranger get a radio but don't work any shifts
      AssetPerson.select(:checked_out).where(person_id: id).each do |ap|
        time_by_year[ap.checked_out.year] ||= []
      end
      time_by_year.each do |year, sheets|
        event = ::BurningMan.find("burning-man-#{year}")
        # TODO set participation status to bonked if they were only an alpha
        # and did not pass mentoring
        involvement = ::Involvement.new :event => event,
          :name => callsign, :barcode => barcode,
          :personnel_status => status, :involvement_status => 'confirmed'
        p.involvements << involvement
        sheets.each do |ts|
          worklog = ts.to_bmem_model
          worklog.event = event
          worklog.involvement = involvement
          involvement.work_logs << worklog
        end
      end
      callsign_status = case status
        when 'prospective', 'alpha', 'bonked', 'uberbonked' then
          callsign =~ /\d{2}|\(NR\)/ ? 'temporary' : 'available'
        when 'active', 'inactive', 'vintage' then 'approved'
        when 'deceased', 'retired' then 'available'
        else 'pending'
      end
      callsign_date = Date.new(time_by_year.keys.max) if time_by_year.any?
      callsign_date ||= status_date
      callsign_date ||= date_verified
      callsign_date ||= Time.zone.now.to_date
      cassign = p.callsign_assignments.build(primary_callsign: true,
        start_date: callsign_date)
      cassign.build_callsign name: callsign, status: callsign_status
      unless p.callsign_assignments.first.valid?
        puts p.callsign_assignments.first.errors.full_messages.to_sentence
      end
      if alternate_callsign.present?
        ac = p.callsign_assignments.build(primary_callsign: false,
          start_date: callsign_date)
        ac.build_callsign name: alternate_callsign, status: 'approved',
          note: 'LEAL callsign'
      end
      p
    end

    def display_name
      callsign
    end

    def full_name
      name = [first_name, mi, last_name].reject(&:empty?).join(' ')
      name.empty? ? callsign : name
    end

    def main_phone
      home_phone
    end

    def phone_numbers
      if main_phone.present? and alt_phone.present?
        "main: #{main_phone}, alt: #{alt_phone}"
      elsif main_phone.present?
        main_phone
      else
        alt_phone
      end
    end

    def birth_date
      birthdate
    end

    def has_personnel_note
      has_note_on_file
    end

    def mailing_address
      line1 = street1
      line2 = street2
      if line2 =~ /box|pmb/i
        pobox = line2
      elsif line1 =~ /box|pmb/i
        pobox = line1
        line1 = line2
        line2 = ''
      end
      extra_address = line2 unless pobox == line2
      if apt.present?
        unit = apt
      elsif line2 =~ /^(unit|suite|apt|lot|#|\d+$)/i
        unit = line2
        extra_address = ''
      end
      unit = "##{unit}" if unit and unit =~ /^\d+$/
      MailingAddress.new extra_address: extra_address,
        street_address: unit ? "#{line1} #{unit}" : line1,
        post_office_box: pobox, locality: city, region: state,
        postal_code: zip, country_name: country
    end

    def to_s
      callsign
    end
  end
end
