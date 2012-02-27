class Ability
  include CanCan::Ability

  def initialize(user)
    if user.nil?
      can :create, User
    else
      # TODO investigate trusted-params gem so HQ et al. can change person
      # fields like status but a normal user can't change his own status
      can :update, User, :id => user.id
      can :read, Schedule::Event, :signup_open => true
      if user.person
        can [:read, :update], [Person, Schedule::Person], :id => user.person.id
        can :read, Schedule::Position, :id => user.person.position_ids
        can :read, Schedule::Slot, :position_id => user.person.position_ids
      end

      if user.has_role? :mentor
        # nothing yet
      end

      if user.has_role? :trainer
        # nothing yet
      end

      if user.has_role? :hq
        can :read, :all
        can :manage, [Person, Schedule::Person]
        can :update, Schedule::Slot
      end

      if user.has_role? :admin
        can :manage, :all
      end
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
