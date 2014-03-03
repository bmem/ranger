var eventController = angular.module('eventController',
    ['scheduleServices', 'restangular']).

controller('EventCtrl', ['$scope', 'eventId', 'Restangular',
    function($scope, eventId, Restangular) {
  $scope.eventId = eventId;
  $scope.$watch('eventId', function(eid) {
    if (eid) {
      $scope.eventResource = Restangular.one('events', eid);
    }
  });
}]);
