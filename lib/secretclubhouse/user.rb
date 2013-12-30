module SecretClubhouse
  class User < ActiveRecord::Base
    include BaseRecord
    PASSWORD_CHARS = (32.chr..126.chr).to_a
    self.table_name = 'person'
    target ::User, :email

    has_and_belongs_to_many :roles, join_table: 'person_role',
      foreign_key: :person_id

    def to_bmem_model
      u = super
      u.person_id = id
      u.password = PASSWORD_CHARS.sample(16).join
      disabled = true # TODO set default to false
      msg = 'Not enabled for test system'
      email = normalize_person_email u.email, self
      if email != u.email
        puts "User #{id} #{u.email} -> #{email}"
        u.email = email
      end
      if email.ends_with? '.invalid'
        disabled = true
        msg = 'No valid email on file'
      end
      unless user_authorized
        disabled = true
        msg = 'User record suspended in Secret Clubhouse'
      end
      case status
      when 'deceased' then disabled, msg = true, 'Person is deceased'
      when 'uberbonked' then disabled, msg = true, 'Dismissed from the Rangers'
      end
      if role_ids.include? 1  # 1 = Administrator
        disabled = false
        msg = ''
        u.user_roles.build user_id: id, role: 'admin'
      end
      u.disabled = disabled
      u.disabled_message = msg
      u
    end

    def to_s
      "User #{callsign}"
    end
  end
end
