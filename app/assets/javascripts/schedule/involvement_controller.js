var involvementController = angular.module('involvementController',
    ['scheduleServices']).

controller('InvolvementCtrl', ['$scope', 'involvementId', function($scope, involvementId) {
  $scope.involvementId = involvementId;
  $scope.$watch('involvementId', function(iid) {
    if (iid) {
      $scope.involvementResource = $scope.eventResource.one('involvements', iid);
      $scope.involvement = $scope.involvementResource.get().$object;
    }
  });
}]);
