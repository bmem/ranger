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

  $scope.hasPosition = function(position) {
    var id = position;
    if (position.id !== undefined) {
      id = position.id;
    }
    return $scope.involvement && $scope.involvement.position_ids &&
      $scope.involvement.position_ids.indexOf(id) >= 0;
  };
}]);
