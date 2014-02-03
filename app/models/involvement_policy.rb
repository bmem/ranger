class InvolvementPolicy < ApplicationPolicy
  MANAGE_ROLES = [Role::ADMIN, Role::HQ_LEAD, Role::PERSONNEL, Role::VC].freeze
  SCHEDULE_ROLES = (MANAGE_ROLES + [Role::HQ, Role::TRAINER_LEAD]).freeze
  VIEW_ROLES = (SCHEDULE_ROLES + [Role::LAMINATES, Role::MENTOR, Role::OPERATOR,
                Role::SHIFT_LEAD]).freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      elsif user.person_id.present?
        scope.where(person_id: user.person_id)
      else
        scope.where("1 = 'Non-person, no access'")
      end
    end
  end

  def list?
    user and user.has_role? *VIEW_ROLES
  end

  def search? ; list? ; end

  def show?
    # Users can view their own involvement record
    record.person_id == user.person_id or user.has_role? *VIEW_ROLES
  end

  def edit?
    # Some field restrictions apply
    show?
  end

  def signup?
    # TODO maybe narrow this
    edit?
  end

  def schedule?
    # TODO let team managers schedule people for their managed positions
    edit? or user.has_role? *SCHEDULE_ROLES
  end

  def create?
    # TODO Special controller method for HQ/Trainers to create involvements
    # for people who didn't mark themselves as planning to participate
    record && user.person_id == record.person_id or user.has_role? *MANAGE_ROLES
  end

  def destroy?
    # Can change status to withdrawn
    user.has_role? Role::ADMIN
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    a = [:audit_comment] + Involvement::DETAIL_ATTRS
    if user.has_role? *VIEW_ROLES
      a << :on_site
    end
    if user.has_role? *MANAGE_ROLES or user.has_role? Role::LAMINATES
      a << :barcode
    end
    if user.has_role? *MANAGE_ROLES
      a << :involvement_status
    end
    if user.has_role? Role::ADMIN
      # Ordinarily, these should go through their own workflow or controllers
      a += [:name, :personnel_status]
    end
    a
  end
end
