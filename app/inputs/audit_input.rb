class AuditInput < Formtastic::Inputs::StringInput
  def input_html_options
    new_class = [super[:class], 'audit-comment'].compact.join(' ')
    super.merge class: new_class, title: placeholder_text
  end

  def placeholder_text
    tip = 'Audit: explain the change you made'
  end

  def localized_label
    localized_string(method, label_from_options || 'Comment', :label)
  end
end
