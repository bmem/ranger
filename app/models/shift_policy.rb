class ShiftPolicy < ApplicationPolicy
  # TODO Only let HQ/Trainer leads create shifts in their own domain?
  MANAGE_ROLES = [Role::ADMIN, Role::HQ_LEAD, Role::TRAINER_LEAD].freeze
  VIEW_ROLES = (MANAGE_ROLES + [Role::HQ, Role::MENTOR, Role::OPERATOR,
    Role::PERSONNEL, Role::SHIFT_LEAD, Role::VC]).freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      # Team managers can list all shifts so they can find an appropriate shift
      # to add their team's positions to
      if user.has_role? *VIEW_ROLES or team_manager?
        scope.where('1 = 1')
      elsif user.person_id.present?
        scope.with_positions(user.person.position_ids)
      else
        scope.where("1 = 'Non-person, no access'")
      end
    end
  end

  def list?
    # Everyone can see shifts they're eligible for
    true
  end

  def show?
    # Users can view their own work logs
    user.has_role? *VIEW_ROLES or team_manager? or
      user.person.try {|p| (record.position_ids & p.position_ids).any?}
  end

  def edit?
    # Team managers can edit shifts if they can manage all slot positions.
    # This lets special teams have full schedule control while requiring admin
    # assistance to change shared shifts.
    manage? or (team_manager? and Set[record.position_ids].subset?(
      Set[user.person.managed_teams.map(&:position_ids).flatten]))
  end

  def create?
    manage? or team_manager?
  end

  def destroy?
    manage?
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    a = [:audit_comment, :name, :description, :start_time, :end_time]
    if manage?
      a += [training: [:instructions, :location, :map_link, :name, {art_ids: []}]]
    end
    if record.new_record?
      # TODO just do a scoped build; don't allow direct /shifts access
      a << :event_id
    end
    a
  end

  private
  def team_manager?
    user.person_id.present? and user.person.managed_team_ids.any?
  end
end
