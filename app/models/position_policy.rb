class PositionPolicy < ApplicationPolicy
  VIEW_ROLES = [Role::ADMIN, Role::HQ, Role::HQ_LEAD, Role::LAMINATES,
    Role::MENTOR, Role::OPERATOR, Role::PERSONNEL, Role::SHIFT_LEAD,
    Role::TRAINER_LEAD, Role::VC].freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      elsif user.person_id.present?
        scope.where(id: user.person.position_ids)
      else
        scope.where("1 = 'Non-person, no access'")
      end
    end
  end

  def list?
    user and user.has_role? *VIEW_ROLES
  end

  def show?
    user.has_role? *VIEW_ROLES
  end

  def people? ; show? ; end

  def edit?
    manage? or record.team.try {|t| t.manager_ids.include? user.person_id}
  end

  def create?
    manage?
  end

  def destroy?
    manage?
  end

  def manage?
    has_role? Role::ADMIN
  end

  def audit? ; manage? ; end

  def permitted_attributes
    a = [:audit_comment, :description, :all_team_members_eligible]
    a += [:name, :team_id, :new_user_eligible] if manage?
    a
  end
end
