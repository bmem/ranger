# Role-based permission definitions.
# See the CanCan wiki to learn how to declare abilities.
# https://github.com/ryanb/cancan/wiki/Defining-Abilities
class Ability
  include CanCan::Ability

  def initialize(user)
    if user.nil?
      can :create, User
    elsif user.person
      me = user.person
      # TODO figure out use cases for non-person users

      if Rails.configuration.users_can_choose_roles_dangerous
        can [:read, :create, :delete], UserRole, :user_id => user.id
      end

      # == Abilities available to everyone ==

      # Personnel abilities
      # TODO investigate a way for HQ et al. to change person fields like status
      # but prevent a normal user from changing his own status
      can :update, User, :id => user.id
      can [:read, :update], Person, :id => me.id
      can :read, Position, :id => me.position_ids

      # Team abilities
      can :read, Team, :id => me.team_ids
      can :edit, Team, :id => me.managed_team_ids

      # Event abilities
      # TODO consider restricting view on events where signup isn't open
      # and historic events a person wasn't involved in
      can :read, Event
      can :create, Involvement, :person_id => me.id, :event => {:signup_open => true}
      can [:read, :update], Involvement, :person_id => me.id
      can :read, WorkLog, :involvement => {:person_id => me.id}
      can :read, Shift.with_positions(me.position_ids)
      can :read, Slot, :position_id => me.position_ids
      # Everyone can see trainings since anyone can attend as a sit-in
      can :read, Training
      # Anyone who can see an event can see credit schemes
      can :read, [CreditScheme, CreditDelta]
      # Anyone can see what an ART is about
      can :read, Art

      if user.has_role? :vc
        # Volunteer coordinators can see everyone's data and manage personal
        # information, callsign, and status
        can [:read, :create, :update], [Person, Involvement]
        can [:read, :update], User
        can :read, [Event, Shift, Slot, WorkLog, Training]
      end

      if user.has_role? :mentor
        # Mentor cadre can change callsigns and personnel status.
        # They can see involvements in all BM and training events, but can only
        # make changes to BurningMan involvements.
        can [:read, :update], Person
        can :read, Involvement
        can [:create, :update], Involvement, :event => {:type => 'BurningMan'}
        can :read, [Event, Shift, Slot, WorkLog, Training]
        # TODO can manage mentor/alpha history
      end

      if user.has_role? :trainer or user.has_role? :trainer_lead
        can :manage, UserRole, :role => ['trainer', 'trainer_lead']
        can :read, Event, :type => 'TrainingSeason'
        # TODO consider only allowing trainers assigned to a training to manage
        can [:read, :update], Training
        # Trainers can create people to record info from folks who show up at
        # a training without creating an account first.
        # TODO consider handling this case with a special controller action
        can [:read, :create], Person
        can :manage, Involvement, :event => {:type => 'TrainingSeason'}
        can :read, Shift, :event => {:type => 'TrainingSeason'}
        can :read, Slot, :event => {:type => 'TrainingSeason'}
        can [:read, :create], WorkLog, :event => {:type => 'TrainingSeason'}
        # TODO manage training outcome model
      end

      if user.has_role? :trainer_lead
        # Trainer leads create trainings
        can :manage, Event, :type => 'TrainingSeason'
        can :manage, [Shift, Slot, WorkLog], :event => {:type => 'TrainingSeason'}
        can :manage, [Training, Art]
      end

      if user.has_role? :hq
        # TODO Restrict access to callsign, name, barcode, status
        can [:read, :update], Person
        can :manage, Involvement, :event => {:type => 'BurningMan'}
        # TODO more fine-grained controls on deleting and changing start time
        can :manage, WorkLog, :event => {:type => 'BurningMan'}
      end

      if user.has_role? :admin
        can :manage, :all
      end
    end
  end
end
