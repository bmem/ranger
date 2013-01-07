module ApplicationHelper
  def person_me
    current_user && current_user.person
  end

  def link_to_record(record, *args)
    link_to record.to_title, record, *args
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
end
