class PeopleController < ApplicationController
  load_and_authorize_resource

  # GET /people
  # GET /people.json
  def index
    @query_statuses = selected_array_param(params[:status])
    @people = @people.where(status: @query_statuses) if @query_statuses.any?
    @people = order_by_params(@people)
    @people = @people.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @people }
    end
  end

  # GET /people/search?q=smith
  # GET /people/search/smith.json
  def search
    @query = params[:q]
    @query_statuses = selected_array_param(params[:status])
    if @query.blank? and @query_statuses.none?
      @people = Person.where('1 = 0').page(1)
      flash.notice = 'Empty search query'
    else
      @query = @query.to_ascii
      @people = @people.where(status: @query_statuses) if @query_statuses.any?
      @people = order_by_params(@people)
      before_query = @people
      @people = @people.with_query(@query).page(params[:page])
      if @people.none? and params[:page].blank? || params[:page] == '1'
        # try a prefix query
        unless @query.starts_with? '^' or @query =~ /\s/
          @query = '^' + @query
          @people = before_query.with_query(@query).page(params[:page])
        end
        flash.notice = 'No people found' if @people.none? # still
      end
    end
    respond_to do |format|
      format.html # search.html.haml
      format.json { render json: @people }
    end
  end

  # GET /people/typehead.json
  # GET /people/typehead.json?q=%5Eprefix
  def typeahead
    if params[:q].present?
      @people = @people.with_query(params[:q]).limit(10)
    else
      @people = @people.where(status: %w(active vintage alpha prospective))
    end
    @dataset = @people.map &:to_typeahead_datum
    respond_to do |format|
      format.json { render :json => @dataset }
    end
  end

  # GET /people/tag/language
  # GET /people/tag/language.json
  # GET /people/tag/language/english
  # GET /people/tag/language/english.json
  def tag
    @tag = params['tag'].try &:pluralize
    tag_name = params['name']
    people = Person.accessible_by(current_ability).order(:display_name)
    people = people.where(:on_playa => true) if params['on_playa']
    if tag_name.present?
      @tagged_people =
          {tag_name => people.tagged_with(tag_name, :on => @tag, :wild => true)}
    elsif @tag.present?
      @tagged_people = Hash.new
      people.tag_counts_on(@tag).each do |t|
        @tagged_people[t.name] = people.tagged_with(t.name, :on => @tag)
      end
    else
      @tag_counts = Hash.new
      people.tag_types.each do |tag|
        @tag_counts[tag.to_s] = people.tag_counts_on(tag)
      end
    end
    respond_to do |format|
      if @tagged_people
        format.html # bylanguage.html.haml
        format.json { render :json => @tagged_people }
      else
        format.html { render :action => 'tag_index' }
        format.json { render :json => @tag_counts }
      end
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @person }
    end
  end

  # GET /people/1/changes
  # GET /people/1/changes.json
  def changes
    @person = Person.find(params[:id])
    authorize! :audit, @person
    @audits = order_by_params @person.audits, default_sort_column: 'version', default_sort_column_direction: 'desc'
    respond_to do |format|
      format.html # changes.html.haml
      format.json { render json: @audits }
    end
  end

  # GET /people/new
  # GET /people/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @person }
    end
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people
  # POST /people.json
  def create
    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, :notice => 'Person was successfully created.' }
        format.json { render :json => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.json { render :json => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.json
  def update
    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to @person, :notice => 'Person was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  def subject_record
    @person
  end

  def default_sort_column
    'display_name'
  end
end
