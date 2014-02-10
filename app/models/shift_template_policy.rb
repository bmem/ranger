class ShiftTemplatePolicy < ApplicationPolicy
  # TODO Only let HQ/Trainer leads create shifts in their own domain?
  MANAGE_ROLES = [Role::ADMIN, Role::HQ_LEAD, Role::TRAINER_LEAD].freeze
  VIEW_ROLES = MANAGE_ROLES # Also team leads

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      # Team managers can list all shifts so they can find an appropriate shift
      # to add their team's positions to
      if user.has_role? *VIEW_ROLES or team_manager?
        scope.where('1 = 1')
      else
        scope.where("1 = 'No access'")
      end
    end
  end

  def list?
    has_role? *VIEW_ROLES or team_manager?
  end

  def show?
    user.has_role? *VIEW_ROLES or team_manager?
  end

  def edit?
    # Team managers can edit shift templatess if they can manage all positions
    # in the slot templates.
    # This lets special teams have full schedule control while requiring admin
    # assistance to change shared shifts.
    manage? or (team_manager? and Set[record.position_ids].subset?(
      Set[user.person.managed_teams.map(&:position_ids).flatten]))
  end

  def create?
    manage? or team_manager?
  end

  def destroy?
    edit?
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    [:audit_comment, :title, :name, :description, :event_type,
      :start_hour, :start_minute, :end_hour, :end_minute]
  end

  private
  def team_manager?
    if_person {|p| p.managed_teams.any?}
  end
end
