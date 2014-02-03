class ProfilePolicy < ApplicationPolicy
  MANAGE_ROLES = [Role::ADMIN, Role::PERSONNEL, Role::VC].freeze
  # TODO Who else needs to see contact information?
  # May need special casing for just email address
  VIEW_ROLES = MANAGE_ROLES

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
    # Profiles hang off person; most folks list people to find people
    user.has_role? *MANAGE_ROLES
  end

  def show?
    edit? or user.has_role? *VIEW_ROLES
  end

  def edit?
    record.person_id? == user.person_id or user.has_role? *MANAGE_ROLES
  end

  def manage?
    user.has_role? *MANAGE_ROLES
  end

  def audit? ; manage? ; end

  def permitted_attributes
    # All fields can be edited
    [ :audit_comment,
      :email, :full_name, :nicknames, :phone_numbers, :contact_note,
      :gender, :birth_date, :shirt_size, :shirt_style, :years_at_burning_man,
      # TODO consider using composed_of for addresses instead
      mailing_address_attributes: [:extra_address, :street_address,
        :post_office_box, :locality, :region, :postal_code, :country_name]
    ]
  end
end
