class AddPositionObserver < ActiveRecord::Observer
  observe Position, Team

  def after_save(model)
    case model
    when Position then handle_position(model)
    when Team then handle_team(model)
    end
  end

  # TODO move new_user_eligible handling from person controller to here

  private
  def handle_position(position)
    if position.all_team_members_eligible? and position.team
      add_members_to_position(position.team, position)
    end
  end

  def handle_team(team)
    team.positions.where(all_team_members_eligible: true).each do |position|
      add_members_to_position(team, position)
    end
  end

  def add_members_to_position(team, position)
    (team.member_ids - position.person_ids).each do |person_id|
      position.people << Person.find(person_id)
    end
  end
end
