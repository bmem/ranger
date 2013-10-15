class CreateMailingAddresses < ActiveRecord::Migration
  def change
    create_table :mailing_addresses do |t|
      t.string :extra_address
      t.string :street_address
      t.string :post_office_box
      t.string :locality
      t.string :region
      t.string :postal_code
      t.string :country_name

      t.timestamps
    end
  end
end
