module ApplicationHelper
  def person_me
    current_user && current_user.person
  end

  def link_to_record(record, *args)
    if record.nil?
      ''
    else
      link_to record.to_title, record, *args
    end
  end

  def link_to_edit_record(record, options = {}, &block)
    name = block_given? ? capture(&block) : 'Edit'
    link_to name, polymorphic_path(record, options.merge(:action => :edit))
  end

  def polymorphic_url(record_hash_array, options = {})
    if record_hash_array.respond_to? :parent_records
      record_hash_array = [record_hash_array.parent_records, record_hash_array].flatten
    elsif record_hash_array.respond_to? :event and record_hash_array.event
      record_hash_array = [record_hash_array.event, record_hash_array]
    end
    super
  end

  def render_if_exists(*args)
    render *args
  rescue ActionView::MissingTemplate
    nil
  end

  def sortable_header(col_name, title = nil, link_options = {},
                      html_options = {}, &block)
    col_name = col_name.to_s
    title ||= col_name.gsub(/.*\./, '').titleize
    css_class = "sortable-header header-#{col_name.gsub(/\W+/, '_')}"
    dir = 'asc'
    if col_name == sort_column
      css_class += " current-sort sort-direction-#{sort_direction}"
      dir = 'desc' if sort_direction == 'asc'
    end
    options = params.merge({sort_column: col_name, sort_direction: dir}.
                           merge(link_options))
    html_options = html_options.merge class: css_class
    if block
      link_to(options, html_options, &block)
    else
      link_to(title, options, html_options)
    end
  end

  def quote_column_name(column_name)
    if column_name.include? '.'
      column_name.split('.').map do |chunk|
        ActiveRecord::Base.connection.quote_column_name chunk
      end.join('.')
    else
      ActiveRecord::Base.connection.quote_column_name column_name
    end
  end
end
