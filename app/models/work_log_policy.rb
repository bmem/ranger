class WorkLogPolicy < ApplicationPolicy
  MANAGE_ROLES = [Role::ADMIN, Role::HQ_LEAD, Role::PERSONNEL].freeze
  CREATE_ROLES = (MANAGE_ROLES + [Role::HQ, Role::TRAINER, Role::TRAINER_LEAD]).freeze
  VIEW_ROLES = (CREATE_ROLES + [Role::MENTOR, Role::OPERATOR, Role::SHIFT_LEAD, Role::VC]).freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      elsif user.person_id.present?
        # TODO consider showing position work logs to team managers
        # If doing that, consider using gem Squeel
        scope.where(involvement_id: user.person.involvement_ids)
      else
        scope.where("1 = 'Non-person, no access'")
      end
    end
  end

  def list?
    user and user.has_role? *VIEW_ROLES
  end

  def show?
    # Users can view their own work logs
    user.has_role? *VIEW_ROLES or record.involvement.person_id == user.person_id
  end

  def edit?
    # HQ Trainers, etc. can only add notes or change positions
    user.has_role? *VIEW_ROLES
  end

  def start?
    # HQ and Trainers can create work logs in their respective domains,
    # but only if the event isn't over
    # TODO Only let trainers add work logs to their own training?
    # TODO Revisit this: Can operators sign themselves in?
    #   Can Shift Leads sign others out?
    record.event.signup_open? and edit? or user.has_role *CREATE_ROLES and
      case record.event.type
      when 'BurningMan' then user.has_role Role::HQ
      when 'TrainingSeason' then user.has_role Role::TRAINER
      else true
      end
  end

  def signin? ; start? ; end

  def stop?
    # If you can sign someone in, you can sign them out
    start?
  end

  def signout? ; stop? ; end

  def create?
    # Managers can create work logs, even retroactively; others should use
    # start?/stop?
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
    a = [:audit_comment, :note]
    if user.has_role? *VIEW_ROLES and record.new_record?
      a << :involvement_id
    end
    if user.has_role? *MANAGE_ROLES
      a += [:position_id, :shift_id, :start_time, :end_time]
    elsif user.has_role? *VIEW_ROLES and record.end_time.blank?
      a += [:position_id, :shift_id]
    end
    a
  end
end
