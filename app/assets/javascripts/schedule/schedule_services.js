var scheduleServices = angular.module('scheduleServices', ['ngResource']).

config(['RestangularProvider', function(RestangularProvider) {
  RestangularProvider.setResponseExtractor(function(resp, operation, what, url) {
    if (what in resp) {
      var newResponse;
      newResponse = resp[what];
      if ('meta' in resp) {
        newResponse._meta = resp['meta'];
      }
      return newResponse;
    } else {
      return resp;
    }
  });

  RestangularProvider.addElementTransformer('shifts', false, function(shift) {
    shift.startMoment = moment(shift.start_time);
    shift.endMoment = moment(shift.end_time);
    // TODO This only produces alternating colors for days when they're all in
    // a row (e.g. burning man), not sparse like trainings.  Create some sort of
    // stateful date latch that only toggles when a threshold is crossed.
    shift.dayClass = shift.startMoment.dayOfYear() % 2 == 0 ? 'day-a' : 'day-b';
    angular.forEach(shift.slots, function(slot) {
      slot.shift = shift;
    });
    return shift;
  });
}]).

factory('eventId', ['$rootElement', function($rootElement) {
  return $rootElement.data('event-id');
}]).

factory('involvementId', ['$rootElement', function($rootElement) {
  return $rootElement.data('involvement-id');
  // TODO set in $rootScope too?
}]).

factory('Involvements', ['$resource', 'eventId', function($resource, eventId) {
  return $resource('/events/:eventId/involvements/:involvementId.json',
    {involvementId: '@id', eventId: eventId},
    {/*actions*/});
}]).

factory('Positions', ['$resource', function($resource) {
  return $resource('/positions/:positionId.json',
    {positionId: '@id'},
    {
      get: {method: 'GET', cache: true},
      query: {method: 'GET', isArray: true, cache: true}
    });
}]).

factory('Shifts', ['$resource', 'eventId', 'involvementId',
    function($resource, eventId, involvementId) {
  return $resource('/events/:eventId/shifts/:shiftId.json',
    {shiftId: '@id', involvementId: involvementId, eventId: eventId},
    {/*actions*/});
}]).

factory('Slots', ['$resource', 'eventId', 'involvementId',
    function($resource, eventId, involvementId) {
  return $resource('/events/:eventId/slots/:slotId.json',
    {slotId: '@id', involvementId: involvementId, eventId: eventId},
    {/*actions*/});
}]);
