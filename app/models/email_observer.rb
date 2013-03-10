# Ensures User and Person email addresses remain in sync
class EmailObserver < ActiveRecord::Observer
  observe :person, :user

  def after_save(record)
    return true unless 'email'.in? record.changed
    case record
    when User then other = record.person
    when Person then other = record.user
    end
    if other && record.email != other.email
      other.email = record.email || other.email
      other.save
    end
  end
end
