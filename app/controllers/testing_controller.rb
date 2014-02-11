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
end
