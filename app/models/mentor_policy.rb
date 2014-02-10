class MentorPolicy < ApplicationPolicy
  # Admins, HQ leads, and motor pool managers can create and edit actual assets.
  # See AssetUse for check out permissions.
  MANAGE_ROLES = [Role::ADMIN, Role::MENTOR]
  VIEW_ROLES = (MANAGE_ROLES + [Role::HQ, Role::HQ_LEAD, Role::OPERATOR,
    Role::PERSONNEL, Role::SHIFT_LEAD, Role::VC]).freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      elsif user.person_id.present?
        scope.where(involvement_id: user.person.involvement_ids)
      else
        scope.where("1 = 'No access'")
      end
    end
  end

  def list?
    has_role? *VIEW_ROLES
  end

  def show?
    has_role? *VIEW_ROLES or
      user.person.try {|p| record.involvement_id.in? p.involvement_ids}
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
    a = [:audit_comment, :involvement_id, :vote, :note]
    if record.new_record?
      a += [:event_id, :mentorship_id]
    end
  end
end
