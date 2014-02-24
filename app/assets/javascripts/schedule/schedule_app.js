var scheduleApp = angular.module('scheduleApp',
    ['scheduleServices', 'scheduleController', 'positionController']).

config(['$httpProvider', function($httpProvider) {
  authToken = $('meta[name="csrf-token"]').attr('content');
  $httpProvider.defaults.headers.common['X-CSRF-TOKEN'] = authToken;
}]);
