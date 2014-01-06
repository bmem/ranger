class Message < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  has_many :receipts, class_name: 'MessageReceipt', dependent: :destroy
  has_many :recipients, class_name: 'Person', through: :receipts
  attr_accessible :body, :expires, :from, :title, :to

  audited

  validates :body, :sender, presence: true
  validates_with ReasonableDateValidator, attributes: [:expires]

  self.per_page = 100

  scope :current, -> {where('expires IS NULL or expires > NOW()')}
  # requires a JOIN with receipts; intended use: person.messages.undelivered
  scope :undelivered, -> {where('NOT message_receipts.delivered')}

  def to_title
    title.presence || '(untitled)'
  end
end
