module SecretClubhouse
  class Asset < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'asset'
    target ::Asset, :type, :name, :designation, :description

    has_many :asset_people

    def to_bmem_model
      a = super
      a = a.becomes(a.type.constantize)
      a.description = temp_id
      a.event = ::BurningMan.find("burning-man-#{year}")
      a.name += '-' while ::Asset.where(event_id: a.event_id, name: a.name).any?
      asset_people.each do |ap|
        au = ap.to_bmem_model
        au.event = a.event
        au.asset = a
        au.involvement = a.event.involvements.find_by_person_id ap.person_id
        print au.errors.full_messages.to_sentence unless au.valid?
        a.asset_uses << au
      end
      return a
    end

    def type
      case description # description column in secret clubhouse is type enum
      when /Radio|Vehicle/
        description
      when 'Key'
        if temp_id =~ /hood/i then 'Asset' else 'Key' end
      else
        'Asset'
      end
    end

    def name
      barcode
    end

    def designation
      case type
      when 'Radio'
        perm_assign? ? ::Radio::EVENT : ::Radio::SHIFT
      when 'Vehicle'
        case barcode
        when /^g/i
          ::Vehicle::GOLF_CART
        when /^r/i
          ::Vehicle::RENTAL
        else
          ::Vehicle::GATOR
        end
      when 'Key'
        case barcode
        when /^df/i
          ::Key::DEEP_FREEZE
        else
          ::Key::BUILDING
        end
      else
        ''
      end
    end

    def year
      y = (create_date || Date.new(2009, 8, 1)).year
      y < 2000 ? 2009 : y # no create dates prior to 2010
    end

    def to_s
      "#{year} #{type} #{name}"
    end
  end
end
