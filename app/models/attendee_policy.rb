class AttendeePolicy < ApplicationPolicy
  # TODO Only let HQ/Trainer leads manage in their own domain?
  MANAGE_ROLES = [Role::ADMIN, Role::HQ_LEAD, Role::TRAINER_LEAD].freeze
  # HQ can add anyone to a shift
  # TODO let trainers add people to their trainings
  SCHEDULE_ROLES = (MANAGE_ROLES + [Role::HQ]).freeze
  VIEW_ROLES = (SCHEDULE_ROLES + [Role::MENTOR, Role::OPERATOR, Role::PERSONNEL,
                Role::SHIFT_LEAD, Role::VC]).freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      else
        if_person do |person|
          scope.where(involvement_id: person.involvement_ids)
        end or scope.where("1 = 'Non-person, no access'")
      end
    end
  end

  def list?
    has_role? *VIEW_ROLES
  end

  def show?
    has_role? *VIEW_ROLES or record.involvement_id.in? involvement_ids
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
    has_role? *SCHEDULE_ROLES
  end

  def create?
    has_role? *SCHEDULE_ROLES or
      record.involvement_id.in?(involvement_ids) && record.slot.try do |slot|
        slot.position_id.in? record.involvement.position_ids
      end
  end

  def destroy?
    has_role? *SCHEDULE_ROLES
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    if has_role? *SCHEDULE_ROLES
      [:audit_comment, :status]
    else
      [:audit_comment]
    end
  end

  private
  def involvement_ids
    if_person {|person| person.involvement_ids} || []
  end
end
