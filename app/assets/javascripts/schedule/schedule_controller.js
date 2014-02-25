var scheduleController = angular.module('scheduleController',
    ['scheduleServices']).

controller('ScheduleCtrl', ['$scope', function($scope) {
  $scope.scheduledSlots = [];

  $scope.$watch('involvement.slot_ids', function(slot_ids) {
    angular.forEach(slot_ids, function(sid) {
      $scope.eventResource.one('slots', sid).get().then(function(slot) {
        $scope.scheduledSlots.push(slot);
      });
    });
  });

  $scope.totalHours = function() {
    var seconds = _.reduce($scope.scheduledSlots, function(sum, slot) {
      return sum + slot.shift.duration_seconds;
    }, 0);
    return seconds / 60.0 / 60.0;
  };

  $scope.totalCredits = function() {
    var seconds = _.reduce($scope.scheduledSlots, function(sum, slot) {
      return sum + Number(slot.credit_value);
    }, 0);
    return seconds;
  };

  $scope.leave = function(slot) {
    alert('Slots.leave({slotId: ' + slot.id + ', involvementId: ' + involvementId + '})');
  };
}]);
