# Base class for model policies.  By default, only admins are allowed to act.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def has_role?(*roles)
    @user.present? and user.has_role? *roles
  end

  def if_person(&block)
    user && user.person.try {|p| yield p}
  end

  def if_person_id(&block)
    user && user.person_id.try {|pid| yield pid}
  end

  def self.default_scope
    Struct.new(:user, :scope) do
      def resolve
        if user.has_role? Role::ADMIN
          scope.all
        else
          scope.where("1 = 'user has no access'")
        end
      end
    end
  end

  def scope
    Pundit.policy_scope! user, record.class
  end

  def list?
    manage? or has_role? Role::ADMIN
  end

  def show?
    manage? or scope.where(id: record.id).exists?
  end

  def create?
    manage? or has_role? Role::ADMIN
  end
  def new? ; create? ; end

  def edit?
    manage? or has_role? Role::ADMIN
  end
  def update? ; edit? ; end

  def destroy?
    manage? or has_role? Role::ADMIN
  end
  def delete? ; destroy? ; end

  def audit?
    has_role? Role::ADMIN
  end
  def changes? ; audit? ; end

  def manage?
    has_role? Role::ADMIN
  end
end
