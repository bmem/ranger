class UserRolePolicy < ApplicationPolicy
  MANAGING_ROLES = Role::BY_MANAGING_ROLE.keys
  VIEW_ROLES = [Role::ADMIN, Role::HQ_LEAD, Role::PERSONNEL, Role::VC].freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      elsif user.has_role? *MANAGING_ROLES
        scope.where(role: managed_roles.map(&:to_sym))
        # TODO OR with user_id = user.id
      elsif user.present?
        scope.where(user_id: user.id)
      else
        scope.where("1 = 'Not logged in; no access'")
      end
    end

    private
    def managed_roles
      UserRolePolicy.new(user, UserRole).managed_roles
    end
  end

  def list?
    has_role? *VIEW_ROLES or has_role? *MANAGING_ROLES
  end

  def show?
    # Users can view their own roles
    has_role? *VIEW_ROLES or user.id == record.user_id or edit?
  end

  def edit?
    manage?
  end

  def create?
    manage?
  end

  def destroy?
    manage?
  end

  def manage?
    managed_roles.include? record.role_obj
  end

  def audit? ; manage? ; end

  def permitted_attributes
    [:audit_comment, :user_id, :role]
  end

  def listable_roles
    has_role?(*VIEW_ROLES) ? Role::ALL : managed_roles
  end

  def managed_roles
    if Rails.configuration.users_can_choose_roles_dangerous and
        (!record.is_a?(UserRole) or record.user == user)
      Role::ALL.sort
    else
      user.roles.flat_map {|r| Role::BY_MANAGING_ROLE[r] || []}.sort.uniq
    end
  end
end
