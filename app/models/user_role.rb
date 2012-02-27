class UserRole < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true
  validate :valid_role

  def role_sym
    role.to_sym
  end

  private
  def valid_role
    if !Role.valid? role
      errors.add(:role, "#{role} is not a valid role")
    end
  end
end
