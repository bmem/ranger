class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :person_attributes

  has_one :person
  accepts_nested_attributes_for :person, :update_only => true
  # TODO don't let person change after creation
  has_many :user_roles

  def roles
    user_roles.map {|ur| Role[ur.role]}
  end

  def has_role?(role)
    Role[role].in? roles
  end

  def to_s
    person ? person.to_s : email
  end

  before_create do |u|
    # Make the first user an admin
    if u.roles.empty? and User.count == 0
      u.user_roles.build(:role => :admin)
    end
  end
end
