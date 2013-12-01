$(document).ready(function() {
  $('.quick-search-box').each(function (i, e) {
    var ttl = 60 * 60 * 1000; // 1 hour
    var datasets = [];
    var eventId = $(e).data('event-id');
    if (eventId) {
      datasets.push({
        name: 'involvements-' + eventId,
        template: JST['search/typeahead_involvement'],
        prefetch: {url: '/events/' + eventId + '/involvements/typeahead.json', ttl: ttl}
      });
    }
    datasets.push({
      name: 'people',
      template: JST['search/typeahead_person'],
      prefetch: {url: '/people/typeahead.json', ttl: ttl},
      // %5E is ^ (prefix search)
      remote: '/people/typeahead.json?q=%5E%QUERY',
    });
    $(e).typeahead(datasets);
    $(e).bind('typeahead:selected', function(evt, datum, datasetName) {
      if (datasetName == 'people') {
        location.assign('/people/' + datum.id);
      } else if (eventId && datasetName == 'involvements-' + eventId) {
        location.assign('/events/' + eventId + '/involvements/' + datum.id);
      }
    });
  });
});
