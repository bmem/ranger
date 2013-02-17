module EmailHelper
  VALID_EMAIL = /^\S+@([a-z0-9\-]+\.)+[a-z0-9\-]{2,}$/i

  def self.append_features(base)
    super
    base.extend ClassMethods
  end

  module ClassMethods
    def normalize_email(email)
      email && email.strip.downcase
    end
  end
end
