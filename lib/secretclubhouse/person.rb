module SecretClubhouse
  class Person < ActiveRecord::Base
    include BaseRecord
    @@rand = Random.new
    self.table_name = 'person'
    target ::Person, :callsign, :full_name, :email, :barcode, :status,
      :position_ids, *::Person::DETAIL_ATTRS

    has_many :timesheets
    has_many :languages
    has_and_belongs_to_many :positions, :join_table => 'person_position'
    has_and_belongs_to_many :roles, :join_table => 'person_role'
    has_and_belongs_to_many :slots, :join_table => 'person_slot'

    def to_bmem_model
      p = super
      if p.email.blank?
        p.email = p.callsign.downcase.gsub(/\W+/, '_') + '@noemail.invalid'
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
      end
      if p.shirt_size == 'Unknown'
        p.shirt_size = nil
      elsif p.shirt_size =~ /XX+L/
        p.shirt_size = "#{p.shirt_size.split(//).count {|c| c == 'X'}}XL"
      end
      if p.shirt_style =~ /Unknown/
        p.shirt_style = nil
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
      time_by_year = timesheets.group_by {|t| t.on_duty.year}
      time_by_year.each do |year, sheets|
        event = ::Event.where(:name => "Burning Man #{year}").first
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
      p
    end

    def full_name
      name = [first_name, mi, last_name].reject(&:empty?).join(' ')
      name.empty? ? callsign : name
    end

    def mailing_address
      "#{street1} #{apt}\n#{street2}\n#{city}, #{state} #{zip}\n#{country}".
        strip.gsub(/\s+\n/, "\n").gsub(/^\s*,\s*$/, '')
    end

    def main_phone
      home_phone
    end

    def birth_date
      birthdate
    end

    def has_personnel_note
      has_note_on_file
    end

    def to_s
      callsign
    end
  end
end
