class PersonPolicy < ApplicationPolicy
  MANAGE_ROLES = [Role::ADMIN, Role::HQ_LEAD, Role::PERSONNEL, Role::VC].freeze
  VIEW_ROLES = (MANAGE_ROLES + [Role::HQ, Role::LAMINATES, Role::MENTOR,
                Role::OPERATOR, Role::SHIFT_LEAD, Role::TRAINER_LEAD]).freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      elsif user.person_id.present?
        scope.where(id: user.person_id)
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
    # Users can view their own person record
    record.id == user.person_id or user.has_role? *VIEW_ROLES
  end

  def edit?
    # Users can't edit their own person record (just their profile record)
    user.has_role? *MANAGE_ROLES
  end

  def copy? ; edit? ; end

  def create?
    # TODO Consider letting trainers create person records for sit-ins
    user.has_role? *MANAGE_ROLES
  end

  def destroy?
    # Deleting a person would lose a lot of historic data
    user.has_role? Role::ADMIN
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    a = [:audit_comment, :full_name, :barcode, :email]
    if user.has_role? *MANAGE_ROLES
      # TODO Let team managers add people to managed positions
      a += [position_ids: []]
    end
    if user.has_role? Role::ADMIN
      # Ordinarily, these should go through their own workflow or controllers
      a += [:display_name, :status]
    end
    a
  end
end
