class ReportPolicy < ApplicationPolicy
  MANAGE_ROLES = [Role::ADMIN].freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user
        # everyone can see their own reports
        scope.where(user_id: user.id)
      else
        scope.where("1 = 'Not logged in'")
      end
    end
  end

  def list?
    # everyone can see their reports
    true
  end

  def show?
    # TODO published reports visible by some group of roles
    record.user_id == user.id
  end

  def edit?
    record.user_id == user.id
  end

  def create?
    # TODO policy for each report type
    manage?
  end

  def generate? ; create? ; end

  def destroy?
    edit?
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; edit? ; end

  def permitted_attributes
    # Report controller sets most attributes directly
    [:audit_comment, :name, :note]
  end
end
