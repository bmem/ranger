class ActiveRecord::Base
  TITLE_ATTRIBUTES = [:title, :display_name, :name, :full_name]

  # Infer a title-suitable string based on this record
  def to_title
    generic = self.class.model_name.human
    title = if new_record? then
      "New #{generic}"
    else
      title_sym = TITLE_ATTRIBUTES.find { |sym| respond_to? sym }
      title_sym ? send(title_sym) : "#{generic} #{id}"
    end
  end

  # to_title is the default to_s implementation
  def to_s
    to_title
  end
end
