class AuditPolicy < ApplicationPolicy
  # Can view any audit.
  VIEW_ROLES = [Role::ADMIN, Role::PERSONNEL].freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      else
        scope.where(user_id: user.id)
      end
    end
  end

  def list?
    has_role? *VIEW_ROLES
  end

  def show?
    has_role? *VIEW_ROLES or record.user_id == user.id
  end
end
