$(document).ready(function() {
  $('.message-quick-send form[data-remote]').
    on('ajax:success', function(e, data, status, xhr) {
      this.reset();
    }).
    on('ajax:error', function(e, data, status, xhr) {
      alert(data.responseText);
    });

  $('table.messages').on('ajax:success', '.action-delete[data-remote]',
    function(e, data, status, xhr) {
      $(this).closest('tbody.message').fadeOut().detach();
    }).on('ajax:error', '.action-delete[data-remote]',
    function(e, data, status, xhr) {
      alert(data.errors.join(', '));
    }).on('ajax:success', '.action-deliver[data-remote]',
    function(e, data, status, xhr) {
      $(this).closest('tbody.message').addClass('delivered').removeClass('undelivered');
      $(this).addClass('hidden');
      $(this).siblings('.action-undeliver').removeClass('hidden');
    }).on('ajax:success', '.action-undeliver[data-remote]',
    function(e, data, status, xhr) {
      $(this).closest('tbody.message').addClass('undelivered').removeClass('delivered');
      $(this).addClass('hidden');
      $(this).siblings('.action-deliver').removeClass('hidden');
    });
});
