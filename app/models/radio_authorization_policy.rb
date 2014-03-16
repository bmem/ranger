class RadioAuthorizationPolicy < AuthorizationPolicy
  MANAGE_ROLES = [Role::ADMIN, Role::HQ, Role::HQ_LEAD].freeze
  VIEW_ROLES = (MANAGE_ROLES + [Role::PERSONNEL, Role::SHIFT_LEAD,
                Role::VEHICLE_LEAD]).freeze

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
end
