class AssetPolicy < ApplicationPolicy
  # Admins, HQ leads, and motor pool managers can create and edit actual assets.
  # See AssetUse for check out permissions.
  MANAGE_ROLES = [Role::ADMIN, Role::HQ_LEAD, Role::VEHICLE_LEAD]
  VIEW_ROLES = (MANAGE_ROLES + [Role::HQ, Role::MENTOR, Role::OPERATOR,
    Role::PERSONNEL, Role::SHIFT_LEAD]).freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      else
        scope.where("1 = 'No access'")
      end
    end
  end

  def list?
    has_role? *VIEW_ROLES
  end

  def show?
    has_role? *VIEW_ROLES
  end

  def people? ; show? ; end

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
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    [:audit_comment, :type, :name, :designation, :description]
  end
end
