module TitleHelper
  def page_title
    chunks = []
    if instance_variable_defined? '@page_title' then
      chunks << @page_title
    else
      record_title.try {|title| chunks << title}
    end
    chunks << controller_name.humanize.capitalize
    section_name = if controller.class.name.include? '::'
      mod_name = controller.class.name.split(/::/)[-2].downcase
      t "module.#{mod_name}", :default => mod_name
    else
      t 'site_name', :default => 'BMEM'
    end
    chunks << section_name
    chunks.join ' :: '
  end

  # The title of the record being displayed or edited, may be nil
  def record_title
    if controller.respond_to? :subject_record then
      controller.subject_record.try { |item| item.to_title }
    end
  end
end
