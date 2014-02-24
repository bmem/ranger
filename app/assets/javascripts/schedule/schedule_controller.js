var scheduleController = angular.module('scheduleController',
    ['scheduleServices']).

controller('ScheduleCtrl', ['$scope', 'involvementId', 'Involvements', 'Shifts', 'Slots',
    function($scope, involvementId, Involvements, Shifts, Slots) {
  $scope.involvementId = involvementId;
  $scope.scheduledSlots = [];

  $scope.involvement = Involvements.get({involvementId: $scope.involvementId},
    function(inv) {
      $scope.scheduledSlots = inv.slots;
    });

  $scope.leave = function(slot) {
    alert('Slots.leave({slotId: ' + slot.id + ', involvementId: ' + involvementId + '})');
  };
}]);
