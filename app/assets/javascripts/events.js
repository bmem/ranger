$(document).ready(function() {
  $('.quick-event-form #default_event_id').change(function() {
    this.form.submit();
    $('input[type=submit]', this.form).attr('disabled', true);
  });
});
