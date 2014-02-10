class UserRole < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true
  validate :valid_role

  attr_accessible :user_id, :role

  audited associated_with: :user

  default_scope order(:role)

  self.per_page = 100

  def role_sym
    role.to_sym
  end

  def role_obj
    Role[role_sym]
  end

  def parent_records
    [user]
  end

  private
  def valid_role
    if !Role.valid? role
      errors.add(:role, "#{role} is not a valid role")
    end
  end
end
