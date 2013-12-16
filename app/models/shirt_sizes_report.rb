class ShirtSizesReport
  def initialize(parameters)
    @event_id = parameters[:event_id]
    @statuses = parameters[:statuses] || []
    @inv_statuses = parameters[:involvement_statuses] || []
  end

  def generate
    if @event_id.present?
      invs = Event.find(@event_id).involvements.includes(:profile)
      invs = invs.where(personnel_status: @statuses) if @statuses.any?
      invs = invs.where(involvement_status: @inv_statuses) if @inv_statuses.any?
      generate_internal(invs) {|inv| [inv.name, inv.personnel_status, inv.profile]}
    else
      people = Person.includes(:profile)
      people = people.where(status: @statuses) if @statuses.any?
      generate_internal(people) {|p| [p.display_name, p.status, p.profile]}
    end
  end

  private
  def generate_internal(source, &tame_status_profile)
    # TODO gem 'multiset'
    by_size = Hash.new {|h,k| h[k] = 0}
    by_gender = Hash.new {|h1,k1| h1[k1] = Hash.new {|h2,k2| h2[k2] = 0}}
    by_style = Hash.new {|h1,k1| h1[k1] = Hash.new {|h2,k2| h2[k2] = 0}}
    by_status = Hash.new {|h1,k1| h1[k1] = Hash.new {|h2,k2| h2[k2] = 0}}
    columns = [:name, :status, :shirt_size, :shirt_style, :gender, :count]
    labels = ['Name', 'Status', 'Shirt size', 'Shirt style', 'Gender', 'Count']
    result = Reporting::KeyValueReport.new key_order: columns,
      key_labels: labels, title: 'Shirt Sizes'
    source.each do |element|
      name, status, profile = yield element
      size = profile.shirt_size
      size = 'Unknown' unless size.present?
      style = profile.shirt_style
      style = 'Unknown' unless style.present?
      by_size[size] += 1
      by_style[style][size] += 1
      by_gender[normalize_gender(profile.gender)][size] += 1
      by_status[status][size] += 1
      result.add_entry name: name, status: status, shirt_size: size,
        shirt_style: style, gender: profile.gender
    end
    by_gender.sort_by(&:first).each do |gender, size_count|
      size_count.sort_by{|p| size_index p.first}.each do |size, count|
        result.add_summary name: 'By Gender',
          shirt_size: size, gender: gender, count: count
      end
    end
    by_style.sort_by(&:first).each do |style, size_count|
      size_count.sort_by{|p| size_index p.first}.each do |size, count|
        result.add_summary name: 'By Style',
          shirt_size: size, shirt_style: style, count: count
      end
    end
    by_status.sort_by(&:first).each do |status, size_count|
      size_count.sort_by{|p| size_index p.first}.each do |size, count|
        result.add_summary name: 'By Status',
          shirt_size: size, status: status, count: count
      end
    end
    by_size.sort_by{|p| size_index p.first}.each do |size, count|
      result.add_summary name: 'Total', shirt_size: size, count: count
    end
    return Reporting::ReportResult.new result, result.entries.length,
      {event: @event_id.present? ? Event.find(@event_id).name : '',
        personnel_status: @statuses.to_sentence,
        involvement_status: @inv_statuses.to_sentence}
  end

  def normalize_gender(gender)
    case gender
    when nil then 'Unknown'
    when /^\s*$/ then 'Unknown'
    when /female|feminine|woman|girl/i then 'Female'
    when /male|masculine|man|boy|dude/i then 'Male'
    when /^f/i then 'Female'
    when /^m/i then 'Male'
    else 'Other'
    end
  end

  def size_index(size)
    Profile::SHIRT_SIZES.index(size) or Profile::SHIRT_SIZES.length
  end
end
