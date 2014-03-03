var scheduleApp = angular.module('scheduleApp', [
  'restangular',
  'checklist-model',
  'scheduleServices',
  'eventController',
  'involvementController',
  'positionController',
  'scheduleController',
]).

config(['$httpProvider', function($httpProvider) {
  authToken = $('meta[name="csrf-token"]').attr('content');
  $httpProvider.defaults.headers.common['X-CSRF-TOKEN'] = authToken;
}]).

config(['RestangularProvider', function(RestangularProvider) {
  RestangularProvider.setRequestSuffix('.json');
}]);
