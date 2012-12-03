class DatePickerInput < Formtastic::Inputs::StringInput
  def input_html_options
    new_class = [super[:class], 'datepicker'].compact.join(' ')
    super.merge(:class => new_class)
  end
end
