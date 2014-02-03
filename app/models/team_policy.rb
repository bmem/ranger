class TeamPolicy < ApplicationPolicy
  VIEW_ROLES = [Role::ADMIN, Role::HQ, Role::HQ_LEAD, Role::LAMINATES,
    Role::MENTOR, Role::OPERATOR, Role::PERSONNEL, Role::SHIFT_LEAD,
    Role::TRAINER_LEAD, Role::VC].freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      elsif user.person_id.present?
        # TODO consider letting people list teams they're a member of
        scope.where(id: user.person.managed_team_ids)
      else
        scope.where("1 = 'Non-person, no access'")
      end
    end
  end

  def list?
    user.try {|u| u.has_role? *VIEW_ROLES or u.person.try {|p| p.managed_teams.any?}}
  end

  def show?
    user.has_role? *VIEW_ROLES
  end

  def edit?
    manage? or record.manager_ids.include? user.person_id
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
    [:audit_comment, :name, :description, {manager_ids: []}, {member_ids: []}]
  end
end
