angular.module('scheduleController', ['scheduleServices']).

controller('ScheduleCtrl', ['$scope', '$log', 'Shifts', 'Attendees',
    function($scope, $log, Shifts, Attendees) {
  $scope.attendees = []
  $scope.allShifts = [];
  $scope.selectedPositionIds = [];
  $scope.availablePositions = [];

  $scope.$watch('involvementId', function(iid) {
    $scope.attendees = Attendees.listForInvolvement(iid);
  });

  $scope.$watch('involvement.position_ids', function(position_ids) {
    $scope.selectedPositionIds = position_ids || [];
    if (_.isEmpty(position_ids)) {
      $scope.allShifts = [];
      $scope.availablePositions = [];
    } else {
      $scope.allShifts = Shifts.listForPositions(position_ids);
      $scope.availablePositions = $scope.involvement.positions;
    }
  });

  $scope.totalHours = function() {
    var seconds = _.reduce($scope.attendees, function(sum, attendee) {
      return sum + (attendee.shift ? attendee.shift.duration_seconds : 0);
    }, 0);
    return seconds / 60.0 / 60.0;
  };

  $scope.totalCredits = function() {
    var seconds = _.reduce($scope.attendees, function(sum, attendee) {
      return sum + Number(attendee.slot.credit_value);
    }, 0);
    return seconds;
  };

  $scope.alreadyIn = function(slot) {
    return _.any($scope.attendees, function(attendee) {
      return attendee.slot_id == slot.id;
    });
  };

  $scope.join = function(slot) {
    if (!$scope.alreadyIn(slot)) {
      Attendees.create($scope.involvementId, slot.id, function(attendee) {
        $scope.attendees.push(attendee);
      }, function(error) {
        $log.error(error);
        var message = 'unknown error, HTTP code ' + error.status;
        if (_.isArray(error.data)) {
          message = error.join(', ');
        } else if (_.isString(error.data) && error.data.length < 512) {
          message = error.data;
        }
        // TODO nicer errors
        alert('Could not join shift: ' + message);
      });
    }
  };

  $scope.leave = function(attendeeOrSlot) {
    var attendee = null;
    if (attendeeOrSlot.slot_id) {
      attendee = attendeeOrSlot;
    } else if (attendeeOrSlot.shift_id) {
      attendee = _.find($scope.attendees, function(att) {
        return att.slot_id == attendeeOrSlot.id;
      });
    }
    if (!attendee) {
      $log.error('Trying to leave ' + attendeeOrSlot + ' but am not in it');
      return;
    }
    Attendees.destroy(attendee.id, function() {
      _.remove($scope.attendees, function(att) {
        return att.id == attendee.id;
      });
    }, function(error) {
      $log.error(error);
      var message = 'unknown error, HTTP code ' + error.status;
      if (_.isArray(error.data)) {
        message = error.join(', ');
      } else if (_.isString(error.data) && error.data.length < 512) {
        message = error.data;
      }
      // TODO nicer errors
      alert('Could not leave shift: ' + message);
    });
  };

  $scope.positionFilter = function(slot) {
    return $scope.selectedPositionIds.length == 0 ||
      $scope.selectedPositionIds.indexOf(slot.position_id) >= 0;
  };

  $scope.availabileSlotFilter = function(slot) {
    return $scope.showFullSlots || slot.max_people <= 0 ||
      slot.max_people > slot.attendees_count;
  };

  $scope.availableShiftFilter = function(shift) {
    return _.every(shift.slots, $scope.availableSlotFilter, this);
  };
}]);
