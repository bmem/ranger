class EventPolicy < ApplicationPolicy
  # require admins to create or modify Event objects
  MANAGE_ROLES = [Role::ADMIN].freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      # everyone can see all events
      scope.where('1 = 1')
    end
  end

  def list?
    # everyone can see all events
    true
  end

  def show?
    # everyone can see all events
    true
  end

  def edit?
    user.has_role? *MANAGE_ROLES
  end

  def create?
    user.has_role? *MANAGE_ROLES
  end

  def destroy?
    user.has_role? Role::ADMIN
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    a = [:audit_comment, :name, :description, :start_date, :end_date,
      :signup_open, :linked_event_id]
    a << :type if record.new_record?
    a
  end
end
