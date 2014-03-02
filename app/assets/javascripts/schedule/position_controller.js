var positionController = angular.module('positionController',
    ['scheduleServices']).

controller('PositionCtrl', ['$scope', 'Restangular', function($scope, Restangular) {
  var query = Restangular.all('positions').getList();
  $scope.positions = query.$object;
  $scope.getPosition = function(id) {
    for (var i = 0; i < $scope.positions.length; ++i) {
      var pos = $scope.positions[i];
      if (pos.id == id) {
        return pos;
      }
    }
    obj = {id: id, name: 'Unknown Position'};
    obj.$object = obj;
    return obj;
  };
}]);
