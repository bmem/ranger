class Profile < ActiveRecord::Base
  include EmailHelper

  SHIRT_SIZES = %w(XS S M L XL 2XL 3XL 4XL)
  SHIRT_STYLES = ['Ladies', 'Mens Regular', 'Mens Tall']
  SUFFIXES =
    %w(JR Jr SR Sr II III IV V VI VII VIII ESQ Esq MD PHD PhD HHP).to_set
  DESIGNATIONS = %w(al ben d' de del der dit du la Mac Mc van von).to_set

  belongs_to :person
  belongs_to :mailing_address
  accepts_nested_attributes_for :mailing_address, update_only: true

  attr_accessible :birth_date, :contact_note, :email, :full_name, :gender,
    :mailing_address_attributes,
    :nicknames, :phone_numbers, :shirt_size, :shirt_style, :years_at_burning_man

  validates :person, presence: true
  validates :full_name, length: { in: 2..64 }
  validates :email, uniqueness: true, allow_blank: true,
    format: EmailHelper::VALID_EMAIL
  validates :shirt_size, inclusion: { in: SHIRT_SIZES }, allow_blank: true
  validates :shirt_style, inclusion: { in: SHIRT_STYLES }, allow_blank: true

  self.per_page = 100

  def self.find_by_email(email)
    self.where(:email => normalize_email(email))
  end

  before_validation do |p|
    p.email = Profile.normalize_email p.email
  end

  def first_name
    split_name.first
  end

  def last_name
    split_name.last
  end

  # A really dirty way to split someone's freeform name into a given name and a
  # family name.  Among countless other problems, this impelmentation doesn't
  # handle Iberian/Latin American double surnames, people who are 9th+ in a
  # family name chain, people whose last name is "Jr", people whose middle name
  # is "Mac", people whose last name is "Fond du Lac", people whose last name
  # is "DEL SOL", people who didn't capitalize MD, and so forth.
  # It does, however, handle people with a one-word name, returning empty string
  # for their last name.
  def split_name
    words = full_name.strip.split
    case words.length
    when 1
      words << ''
    when 2
      words
    else
      last_words = []
      while words.length > 2 and words.last.gsub(/[,.]/, '').in? SUFFIXES do
        last_words.unshift words.pop
      end
      last_words.unshift words.pop
      while words.length > 1 and words.last.in? DESIGNATIONS do
        last_words.unshift words.pop
      end
      [words.join(' '), last_words.join(' ')]
    end
  end
end
