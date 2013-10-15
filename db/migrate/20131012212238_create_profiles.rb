class CreateProfiles < ActiveRecord::Migration
  ADDRESS_RE = /^(.+)\n(.+\n)?(.+),\s*(\w+)\s*(.*)\n(.+)?$/

  def up
    create_table :profiles do |t|
      t.references :person
      t.string :full_name
      t.string :nicknames
      t.string :email
      t.string :phone_numbers
      t.references :mailing_address
      t.text :contact_note
      t.string :gender
      t.date :birth_date
      t.string :shirt_size
      t.string :shirt_style
      t.string :years_at_burning_man

      t.timestamps
    end
    add_index :profiles, :person_id
    add_index :profiles, :mailing_address_id

    Person.order(:id).each do |p|
      phones = if p.main_phone.present? and p.alt_phone.present?
        "main: #{p.main_phone}, alt: #{p.alt_phone}"
        elsif p.main_phone.present?
          p.main_phone
        else
          p.alt_phone
        end
      address = {}
      if p.mailing_address.present?
        if match = ADDRESS_RE.match(p.mailing_address)
          if match[2].present?
            address[:extra_address] = match[1]
            address[:street_address] = match[2]
          else
            address[:street_address] = match[1]
          end
          address[:locality] = match[3]
          address[:region] = match[4]
          address[:postal_code] = match[5]
          address[:country_name] = match[6]
        end
      end
      p.create_profile! full_name: p.full_name, email: p.email,
        phone_numbers: phones, mailing_address_attributes: address,
        gender: p.gender, birth_date: p.birth_date, shirt_size: p.shirt_size,
        shirt_style: p.shirt_style
    end
  end

  def down
    remove_index :profiles, :person_id
    remove_index :profiles, :mailing_address_id
    drop_table :profiles
  end
end
