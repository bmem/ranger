class MessageReceipt < ActiveRecord::Base
  belongs_to :message
  belongs_to :recipient, class_name: 'Person'
  attr_accessible :delivered, :deleted

  audited associated_with: :recipient

  validates :message, :recipient, presence: true
  validates :delivered, inclusion: {in: [true, false]}
  before_validation :set_defaults
  #before_validation_on_create :set_defaults

  default_scope -> {where(deleted: false)}
  scope :undelivered, -> {where(delivered: false).includes(:message)}

  private
  def set_defaults
    delivered = false if delivered.nil? and new_record?
    deleted = false if deleted.nil? and new_record?
    true # don't prevent validation
  end
end
