class SlotTemplatePolicy < ApplicationPolicy
  MANAGE_ROLES = [Role::ADMIN, Role::HQ_LEAD, Role::TRAINER_LEAD].freeze
  VIEW_ROLES = MANAGE_ROLES # Also team leads

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES or team_manager?
        scope.where('1 = 1')
      else
        scope.where("1 = 'No access'")
      end
    end
  end

  def list?
    # Everyone can see slots they're eligible for
    has_role? *VIEW_ROLES or team_manager?
  end

  def show?
    user.has_role? *VIEW_ROLES or team_manager?
  end

  def edit?
    # Team managers can edit slots for their teams.
    manage? or (team_manager? and record.position_id.in? managed_position_ids)
  end

  def create?
    manage? or (team_manager? and (record.position_id.blank? or
                                   record.position_id.in? managed_position_ids))
  end

  def destroy?
    edit?
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    [:audit_comment, :shift_template_id, :position_id, :min_people, :max_people]
  end

  private
  def team_manager?
    user.person_id.present? and user.person.managed_team_ids.any?
  end

  def managed_position_ids
    user.person.try {|p| p.managed_teams.map(&:position_ids)} || []
  end
end
