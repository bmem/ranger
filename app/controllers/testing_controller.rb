class TestingController < ApplicationController
  before_filter :authenticate_user!

  # GET /testing
  def index
    @user = current_user
    @remote_ip = request.remote_ip
    # render index.html.haml
  end

  # GET /mask_roles
  def mask_roles
    # TODO also allow pretending you're not a team manager?
    @roles = current_user.roles
    @masked_roles = current_user.masked_roles || []
    respond_to do |format|
      format.html # mask_roles.html.haml
      format.json {render json: {roles: @roles, masked_roles: @masked_roles}}
    end
  end

  # POST /mask_roles?mask_roles[admin]=1
  def update_mask_roles
    to_mask = selected_array_param(params[:mask_roles]).
      map {|r| Role[r].to_sym}.uniq
    session[:masked_roles] = to_mask.presence
    respond_to do |format|
      format.html {redirect_to testing_mask_roles_path}
      format.json {render json: {roles: current_user.roles, masked_roles: current_user.masked_roles}}
    end
  end

  # GET /populate_event
  def populate_event
    # TODO make a TestingPolicy
    raise Pundit::NotAuthorizedError unless current_user.has_role? Role::ADMIN
    @events = policy_scope(Event)
    respond_to do |format|
      format.html # populate_event.html.haml
    end
  end

  # POST /update_populate_event
  def update_populate_event
    # TODO make a TestingPolicy
    raise Pundit::NotAuthorizedError.new('Must be an admin') unless current_user.has_role? Role::ADMIN
    source = Event.find(params[:source_event_id])
    destination = Event.find(params[:destination_event_id])
    raise 'Must specify different events' unless source != destination
    existing = destination.person_ids.to_set
    involvements = source.involvements
    selected_array_param(params[:involvement_status]).presence.try do |statuses|
      involvements = involvements.where(involvement_status: statuses)
    end
    created = 0
    Involvement.transaction do
      involvements.includes(:person).each do |sourceinv|
        p = sourceinv.person
        unless p.id.in? existing
          inv = destination.involvements.build name: p.display_name,
            personnel_status: p.status, involvement_status: 'planned',
            barcode: p.barcode, camp_location: sourceinv.camp_location,
            emergency_contact_info: sourceinv.emergency_contact_info
          inv.person = p
          inv.save!
          created += 1
        end
      end
    end
    respond_to do |format|
      format.html {redirect_to testing_populate_event_path, notice: "Added #{created} #{'person'.pluralize(created)} to #{destination}"}
    end
  end
end
