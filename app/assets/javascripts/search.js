$(document).ready(function() {
  $('.quick-search-box').each(function (i, e) {
    var ttl = 60 * 60 * 1000; // 1 hour
    var datasets = [];
    var eventId = $(e).data('event-id');
    if (eventId) {
      datasets.push({
        name: 'involvements-' + eventId,
        prefetch: {url: '/events/' + eventId + '/involvements/typeahead_prefetch.json', ttl: ttl}
      });
    }
    datasets.push({
      name: 'people',
      prefetch: {url: '/people/typeahead_prefetch.json', ttl: ttl}
    });
    $(e).typeahead(datasets);
  });
});
