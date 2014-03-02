var scheduleController = angular.module('scheduleController',
    ['scheduleServices']).

controller('ScheduleCtrl', ['$scope', '$log', function($scope, $log) {
  $scope.allShifts = [];
  $scope.scheduledSlots = [];

  $scope.$watch('involvement.slot_ids', function(slot_ids) {
    existing = _.map($scope.scheduledSlots, function(s) { return s.id });
    angular.forEach(_.difference(slot_ids, existing), function(sid) {
      $scope.eventResource.one('slots', sid).get().then(function(slot) {
        $scope.scheduledSlots.push(slot);
        $scope.eventResource.one('shifts', slot.shift_id).get().then(function(shift) {
          slot.shift = shift;
        });
      });
    });
    angular.forEach(_.difference(existing, slot_ids), function(sid) {
      _.remove($scope.scheduledSlots, function(slot) {
        return slot.id == sid;
      });
    });
  }, true /* isArray */);
  $scope.$watch('eventResource', function(eventResource) {
    $scope.allShifts = []
    var params = {involvement_id: $scope.involvementId};
    var shiftsResource = eventResource.all('shifts');
    function loadShifts(shifts) {
      $scope.allShifts = $scope.allShifts.concat(shifts);
      if (shifts._meta && shifts._meta.total_pages) {
        var page = Number(shifts._meta.page);
        var total = Number(shifts._meta.total_pages);
        if (page < total) {
          shiftsResource.getList(_.merge(params, {page: page + 1})).
            then(loadShifts);
        }
      }
    }
    shiftsResource.getList(params).then(loadShifts);
  });

  $scope.totalHours = function() {
    var seconds = _.reduce($scope.scheduledSlots, function(sum, slot) {
      return sum + (slot.shift ? slot.shift.duration_seconds : 0);
    }, 0);
    return seconds / 60.0 / 60.0;
  };

  $scope.totalCredits = function() {
    var seconds = _.reduce($scope.scheduledSlots, function(sum, slot) {
      return sum + Number(slot.credit_value);
    }, 0);
    return seconds;
  };

  $scope.alreadyIn = function(slot) {
    return $scope.involvement && $scope.involvement.slot_ids &&
      $scope.involvement.slot_ids.indexOf(slot.id) >= 0;
  };

  $scope.join = function(slot) {
    $log.info('Slots.join({slotId: ' + slot.id + ', involvementId: ' + $scope.involvementId + '})');
    if (!$scope.alreadyIn(slot)) {
      $scope.involvement.slot_ids.push(slot.id);
    }
  };

  $scope.leave = function(slot) {
    $log.info('Slots.leave({slotId: ' + slot.id + ', involvementId: ' + $scope.involvementId + '})');
    _.remove($scope.involvement.slot_ids, function(x) {
      return x == slot.id;
    });
  };
}]);
