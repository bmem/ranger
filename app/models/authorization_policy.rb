class AuthorizationPolicy < ApplicationPolicy
  # Subclasses have other roles
  MANAGE_ROLES = [Role::ADMIN].freeze
  VIEW_ROLES = (MANAGE_ROLES + [Role::HQ, Role::HQ_LEAD, Role::PERSONNEL,
                Role::SHIFT_LEAD, Role::VEHICLE_LEAD]).freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.scoped
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

  def edit?
    has_role? *MANAGE_ROLES
  end

  def create?
    has_role? *MANAGE_ROLES
  end

  def destroy?
    has_role? *MANAGE_ROLES
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    result = [:audit_comment]
    if record.new_record?
      result += [:involvement_id, :type]
    end
    result
  end

  protected
  def involvement_ids
    if_person {|person| person.involvement_ids} || []
  end
end
