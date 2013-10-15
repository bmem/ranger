class MailingAddress < ActiveRecord::Base
  # Field names are based on vCard
  ADDRESS_ATTRS = [:extra_address, :street_address, :post_office_box, :locality,
    :region, :postal_code, :country_name]
  attr_accessible *ADDRESS_ATTRS

  before_validation do |a|
    ADDRESS_ATTRS.each do |attr|
      val = a.send attr
      a.send "#{attr}=", val.strip unless val.nil?
    end
  end

  def to_s
    lines = [extra_address, street_address, box_line, city_state_zip,
      country_name].find_all(&:present?).map(&:strip).join("\n")
  end

  def box_line
    if post_office_box.present? and post_office_box !~ /box|pmb/i
      "PO Box #{post_office_box}"
    else
      post_office_box
    end
  end

  def city_state_zip
    if locality.present? and (region.present? or postal_code.present?)
      "#{locality}, #{region} #{postal_code}".strip
    elsif region.present? or postal_code.present?
      "#{region} #{postal_code}".strip
    else
      locality
    end
  end
end
