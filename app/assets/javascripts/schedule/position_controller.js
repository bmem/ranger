var positionController = angular.module('positionController',
    ['scheduleServices']).

controller('PositionCtrl', ['$scope', 'Positions', function($scope, Positions) {
  $scope.positions = Positions.query();
  $scope.getPosition = function(id) {
    for (var i = 0; i < $scope.positions.length; ++i) {
      var pos = $scope.positions[i];
      if (pos.id == id) {
        return pos;
      }
    }
    return {id: id, name: 'Unknown Position'};
  };
}]);
