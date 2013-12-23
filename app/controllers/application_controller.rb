class ApplicationController < ActionController::Base
  helper TitleHelper
  helper_method :sort_column, :sort_direction

  protect_from_forgery

  before_filter :set_default_event_id

  rescue_from CanCan::AccessDenied do |ex|
    if current_user
      redirect_back :alert => ex.message
    else
      redirect_to new_user_session_path, :alert => ex.message
    end
  end

  protected
  def redirect_back(*args)
    target = root_url
    if request.env["HTTP_REFERER"].try {|s| s.start_with? root_url}
      # user came from our site
      target = :back
    end
    redirect_to target, *args
  end

  # Useful for turning a bunch of checkboxes into an array.
  def selected_array_param(param)
    case param
    when String
      [param]
    when Array
      param
    when Hash
      param.find_all {|k, v| v.present?}.map &:first
    else
      []
    end
  end

  # Determine the default event ID when none is specified in the request
  def default_event_id
    [@default_event_id, session[:default_event_id],
      Ranger::Application.config.default_event_id].find &:present?
  end

  def set_default_event_id
    @default_event_id ||= default_event_id
  end

  # GET /items?sort_column=name&sort_direction=desc
  # @items = order_by_params(Item.where(...))

  def order_by_params(relation, options = {})
    options = options.reverse_merge default_sort_column: default_sort_column,
      default_sort_column_direction: default_sort_column_direction
    dcol = options[:default_sort_column_direction]
    sort_column(options).try do |col|
      relation = relation.reorder(
        "#{tweak_sort_column col, relation} #{sort_direction(options)}")
    end
    relation = default_order(relation, options) if sort_column != dcol
    relation
  end

  def sort_column(options = {})
    options = options.reverse_merge default_sort_column: default_sort_column
    params[:sort_column].try {|s| s if valid_sort_column? s} or
      options[:default_sort_column]
  end

  def sort_direction(options = {})
    params[:sort_direction].try {|dir| dir if %w(asc desc).include? dir} or
      options[:default_sort_column_direction] or 'asc'
  end

  def valid_sort_column?(column_name)
    column_name =~ /^\w+(\.\w+)*$/
  end

  def tweak_sort_column(column_name, relation = nil)
    if relation and relation.columns_hash.keys.include? column_name
      is_str = :string == relation.columns_hash[column_name].type
    else
      is_str = column_name =~ /name|title|description|note/
    end
    is_str ? "LOWER(#{column_name})" : column_name
  end

  def default_sort_column
    nil
  end

  def default_sort_column_direction
    nil
  end

  def default_order(relation, options = {})
    options = options.reverse_merge default_sort_column: default_sort_column,
      default_sort_column_direction: default_sort_column_direction,
      sort_direction: sort_direction
    options[:default_sort_column].try do |dcol|
      dir = options[:default_sort_column_direction] || options[:sort_direction]
      relation = relation.order("#{tweak_sort_column dcol} #{dir}")
    end
    relation
  end
end
