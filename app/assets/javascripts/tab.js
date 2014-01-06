$(document).ready(function() {
  $('.tab-container').tabs();
  $(window).bind('hashchange', function() {
    var hash = document.location.hash.substr(1);
    if (hash != '') {
      $('.tab-container a[href=#' + hash + ']').click();
    }
  });
});
