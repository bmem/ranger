var involvementController = angular.module('involvementController',
    ['scheduleServices']).

controller('InvolvementCtrl', ['$scope', 'Involvements', 'involvementId',
    function($scope, Involvements, involvementId) {
  $scope.involvementId = involvementId;
  $scope.$watch('involvementId', function(iid) {
    if (iid) {
      $scope.involvement = Involvements.get(iid);
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
