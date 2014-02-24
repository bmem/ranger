var scheduleServices = angular.module('scheduleServices', ['ngResource']).

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
