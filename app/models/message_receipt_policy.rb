class MessageReceiptPolicy < ApplicationPolicy
  # Sending and delivering is available to HQ and operations folks.
  # Off-playa messages about training, new volunteer intake, etc. go through
  # email rather than clubhouse messages.
  MANAGE_ROLES = [Role::ADMIN, Role::HQ_LEAD, Role::PERSONNEL].freeze
  SEND_ROLES = (MANAGE_ROLES + [Role::HQ, Role::LAMINATES, Role::OPERATOR,
    Role::SHIFT_LEAD]).freeze
  VIEW_ROLES = SEND_ROLES

  self::Scope = Struct.new(:user, :scope) do
    def resolve
      # Managers can list all messages; others can see messages on person page
      if user.has_role? *VIEW_ROLES
        scope.where('1 = 1')
      elsif user.person_id.present?
        scope.where(recipient_id: user.person_id)
      else
        scope.where("1 = 'No user; no access'")
      end
    end
  end

  def list?
    has_role? *MANAGE_ROLES
  end

  def show?
    # Users can view messages addressed to them
    has_role? *VIEW_ROLES or user.id == record.message.sender_id or
      if_person_id {|pid| pid == record.recipient_id}
  end

  def deliver?
    has_role? *SEND_ROLES or if_person_id {|pid| pid == record.recipient_id}
  end

  def edit?
    deliver?
  end

  def create?
    # Team managers can send messages to their team members
    has_role? *SEND_ROLES or if_person {|p| p.managed_teams.any?}
  end

  def destroy?
    # TODO Don't let some people delete receipts?
    deliver?
  end

  def manage?
    has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    [:audit_comment, :delivered, :deleted]
  end
end
