class AssetUsePolicy < ApplicationPolicy
  # Admins, HQ leads, and motor pool managers can edit recorded data.
  # HQ, shift leads, et al can check assets out and change extras/notes.
  MANAGE_ROLES = [Role::ADMIN, Role::HQ_LEAD]
  CREATE_ROLES = (MANAGE_ROLES + [Role::HQ, Role::MENTOR, Role::OPERATOR,
    Role::PERSONNEL, Role::SHIFT_LEAD]).freeze
  VIEW_ROLES = CREATE_ROLES

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      elsif user.person_id.present?
        scope.where(involvement_id: user.person.involvement_ids)
      else
        scope.where("1 = 'Non-person; no access'")
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

  def people? ; show? ; end

  def edit?
    has_role? *CREATE_ROLES
  end

  def create?
    has_role? *CREATE_ROLES
  end

  def destroy?
    manage?
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    a = [:audit_comment, :extra, :note]
    if manage? or record.new_record?
      a += [:asset_id, :involvement_id, :checked_out]
    end
    if manage? or record.currently_out?
      a+= [:checked_out, :due_in]
    end
    a
  end
end
