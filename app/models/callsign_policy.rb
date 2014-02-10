class CallsignPolicy < ApplicationPolicy
  MANAGE_ROLES = [Role::ADMIN, Role::PERSONNEL, Role::VC, Role::MENTOR].freeze
  VIEW_ROLES = (MANAGE_ROLES + [Role::HQ, Role::HQ_LEAD, Role::LAMINATES,
    Role::OPERATOR, Role::SHIFT_LEAD]).freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      # Everyone can list callsigns (so noobs can pick an available one)
      if user
        scope.where('1 = 1')
      else
        scope.where("1 = 'Not logged in'")
      end
    end
  end

  def list?
    # Everyone can list callsigns (so noobs can pick an available one)
    user.present?
  end

  def show?
    # Not everyone can see details, though
    record.status == 'reserved' or user.has_role? *MANAGE_ROLES or
      user.person_id.try {|pid| record.person_ids.include? pid}
  end

  def edit?
    manage?
  end

  def create?
    # TODO put more process around creating callsigns
    manage? or record.status.in? %w(pending temporary)
  end

  def manage?
    user.has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    # TODO Consider letting requesters add notes to their callsign
    [ :audit_comment, :name, :status, :note ]
  end
end
