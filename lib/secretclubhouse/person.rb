module SecretClubhouse
  class Person < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'person'
    target ::Person, :callsign, :full_name, :email, :barcode, :status,
      :position_ids, *::Person::DETAIL_ATTRS

    has_many :timesheets
    has_and_belongs_to_many :positions, :join_table => 'person_position'

    def to_bmem_model
      p = super
      if p.shirt_size = 'Unknown'
        p.shirt_size = nil
      elsif p.shirt_size =~ /XX+L/
        p.shirt_size = "#{p.shirt_size.split(//).count {|c| c == 'X'}}L"
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
