class UserPolicy < ApplicationPolicy
  MANAGER_ROLES = [Role::ADMIN, Role::VC, Role::PERSONNEL].freeze

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      if user.has_role? *MANAGER_ROLES
        scope.where('1 = 1')
      else
        scope.where(id: user.id)
      end
    end
  end

  def show?
    # Users can view their own information
    record == user or manage?
  end

  # TODO figure out rules for create

  def edit?
    # Users can edit some user information (see also: disable?)
    record == user or manage?
  end

  def destroy?
    # Only admins can delete user accounts, since it's a fairly extreme measure
    has_role? Role::ADMIN
  end

  def manage?
    # Admins, volunteer coordinators, and personnel managers are the sorts of
    # folks people will turn to when their account doesn't work
    has_role? *[Role::ADMIN, Role::VC, Role::PERSONNEL]
  end

  def disable?
    # These folks can prevent users from logging in
    manage?
  end

  def permitted_attributes
    a = [:email]
    if disable?
      a += [:disabled, :disabled_message]
    end
    # TODO consider letting managers set users' passwords directly
    a
  end
end
