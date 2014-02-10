class SlotPolicy < ApplicationPolicy
  # TODO Only let HQ/Trainer leads create slots in their own domain?
  MANAGE_ROLES = [Role::ADMIN, Role::HQ_LEAD, Role::TRAINER_LEAD].freeze
  # HQ can add anyone to a shift
  SCHEDULE_ROLES = (MANAGE_ROLES + [Role::HQ]).freeze
  VIEW_ROLES = (SCHEDULE_ROLES + [Role::MENTOR, Role::OPERATOR, Role::PERSONNEL,
                Role::SHIFT_LEAD, Role::VC]).freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      # Team managers can list all shifts so they can find an appropriate shift
      # to add their team's positions to
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      elsif relevant_position_ids.present?
        scope.where(position_id: relevant_position_ids.to_a)
      else
        scope.where("1 = 'Non-person, no access'")
      end
    end

    private
    def relevant_position_ids
      SlotPolicy.new(user, Slot.new).relevant_position_ids
    end
  end

  def list?
    # Everyone can see slots they're eligible for
    true
  end

  def show?
    user.has_role? *VIEW_ROLES or record.position_id.in? relevant_position_ids
  end

  def join?
    # TODO allow people to sign themselves up, which requires knowing the param
    # which isn't a record attribute.  Maybe make a join model.
    user.has_role? *SCHEDULE_ROLES or
      team_manager? and record.position_id.in? managed_position_ids
  end

  def leave?
    user.has_role? *SCHEDULE_ROLES or
      team_manager? and record.position_id.in? managed_position_ids
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
    manage?
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    [:audit_comment, :shift_id, :position_id, :min_people, :max_people]
  end

  def team_manager?
    user.person_id.present? and user.person.managed_team_ids.any?
  end

  def relevant_position_ids
    Set.new(user.person.try {|p| p.position_ids + managed_position_ids} || [])
  end

  def managed_position_ids
    user.person.try {|p| p.managed_teams.map(&:position_ids)} || []
  end
end
