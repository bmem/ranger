class CreditDeltaPolicy < ApplicationPolicy
  # Consider creating an OPS_MANAGER role that can manage credit deltas, etc.
  MANAGE_ROLES = [Role::ADMIN].freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user
        # everyone can see all deltas
        scope.where('1 = 1')
      else
        scope.where("1 = 'Not logged in'")
      end
    end
  end

  def list?
    # everyone can see all credit deltas
    true
  end

  def show?
    # everyone can see all credit deltas
    true
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
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    a = [:audit_comment, :name, :hourly_rate, :start_time, :end_time]
    a << :credit_scheme_id if record.new_record?
    a
  end
end
