$(document).ready(function() {
  $('.quick-search-box').each(function (i, e) {
    var ttl = 4 * 60 * 60 * 1000; // 4 hours
    var datasets = [];
    var eventId = $(e).data('event-id');
    if (eventId) {
      datasets.push({
        name: 'involvements-' + eventId,
        template: JST['search/typeahead_involvement'],
        prefetch: {
          url: '/events/' + eventId + '/involvements/typeahead.json',
          ttl: ttl,
          filter: _.property('involvements')
        }
      });
    }
    datasets.push({
      name: 'people',
      template: JST['search/typeahead_person'],
      prefetch: {
        url: '/people/typeahead.json',
        ttl: ttl,
        filter: _.property('people')
      },
      // %5E is ^ (prefix search)
      remote: {
        url: '/people/typeahead.json?q=%5E%QUERY',
        filter: _.property('people')
      }
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
