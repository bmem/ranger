class CallsignAssignmentPolicy < ApplicationPolicy
  MANAGE_ROLES = CallsignPolicy::MANAGE_ROLES
  VIEW_ROLES = CallsignPolicy::VIEW_ROLES

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      # Everyone can list callsigns (so noobs can pick an available one)
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      elsif user.person_id.present?
        scope.where(person_id: user.person_id)
      else
        scope.where("1 = 'Non-user person; no access'")
      end
    end
  end

  def list?
    # View folks normally just list callsigns, then see details
    user.has_role? *MANAGE_ROLES
  end

  def show?
    # Not everyone can see details, though
    user.has_role? *VIEW_ROLES or user.person_id == record.person_id
  end

  def edit?
    manage?
  end

  def create?
    # TODO put more process around creating callsigns
    manage? or record.callsign.status.in? %w(pending temporary)
  end

  def manage?
    user.has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    [ :audit_comment, :start_date, :end_date, :primary_callsign ]
  end
end
