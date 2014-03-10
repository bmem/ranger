angular.module('scheduleServices', ['restangular']).

config(['RestangularProvider', function(RestangularProvider) {
  RestangularProvider.setResponseExtractor(function(resp, operation, what, url) {
    if (!resp) { // 204 No Content
      return resp;
    }
    // TODO inflections
    // TODO ES6 Harmony Polyfill for endsWith
    if (!(what in resp) && what.match(/s$/)) {
      var whatSingular = what.replace(/s$/, '');
      if (whatSingular in resp) {
        what = whatSingular;
      }
    }
    if (what in resp) {
      // e.g. {things: [{id: 42, owner_id: 123, ...}], owners: [{id: 123, ...}]}
      // want to return [{id: 42, owner_id: 123, owner: {id: 123, ...}}]
      // _meta (e.g. pagination) and _response (original response) also present
      var newResponse;
      newResponse = resp[what];
      newResponse._response = resp;
      // build a cache of nestable objects from collections in the response
      var byId = {};
      _.forOwn(resp, function(val, key) {
        if (key == what) {
          // do nothing
        } else if (key == 'meta') {
          newResponse._meta = val;
        } else if (_.isArray(val)) {
          byId[key] = _.indexBy(val, _.property('id'));
        }
      });
      function setObjects(obj) {
        _.forOwn(obj, function(val, key) {
          // TODO inflections
          if (key.match(/_ids$/) && _.isArray(val)) {
            var plural = key.replace(/_ids$/, 's');
            if (plural in byId && !(plural in obj)) {
              obj[plural] = _.map(val, function(nestedId) {
                return byId[plural][nestedId];
              });
            }
          } else if (key.match(/_id$/)) {
            var plural = key.replace(/_id$/, 's');
            var singular = key.replace(/_id$/, '');
            if (singular != key && plural in byId && !obj[singular]) {
              obj[singular] = byId[plural][val];
            }
            if (_.isArray(val)) {
              _.forEach(val, function(subObj) {
                setObjects(subObj);
              });
            }
          }
        });
      };
      // apply nested objects to other nested objects
      _.forOwn(byId, function(objCollection) {
        _.forOwn(objCollection, setObjects);
      });
      // apply nested objects to result array
      if (_.isArray(newResponse)) {
        _.forEach(newResponse, setObjects);
      } else {
        setObjects(newResponse);
      }
      return newResponse;
    } else {
      return resp;
    }
  });

  RestangularProvider.addElementTransformer('shifts', false, function(shift) {
    shift.startMoment = moment(shift.start_time);
    shift.endMoment = moment(shift.end_time);
    // TODO This only produces alternating colors for days when they're all in
    // a row (e.g. burning man), not sparse like trainings.  Create some sort of
    // stateful date latch that only toggles when a threshold is crossed.
    shift.dayClass = shift.startMoment.dayOfYear() % 2 == 0 ? 'day-a' : 'day-b';
    angular.forEach(shift.slots, function(slot) {
      slot.shift = shift;
    });
    return shift;
  });
}]).

factory('PaginatedLoader', [function() {
  return {
    loadAllPages: function(resource, params) {
      var loaded = {};
      var deferred = resource.getList(params);
      var result = deferred.$object;
      function loadNextPage(resp) {
        _.forEach(resp, function(obj) {
          if (!obj.id || !loaded[obj.id]) {
            result.push(obj);
            loaded[obj.id] = true;
          }
        });
        if (resp._meta && resp._meta.total_pages) {
          var page = Number(resp._meta.page);
          var total = Number(resp._meta.total_pages);
          if (page < total) {
            resource.getList(_.merge(params, {page: page + 1})).then(loadNextPage);
          }
        }
      }
      deferred.then(function(firstResponse) {
        _.forEach(firstResponse, function(obj) {
          loaded[obj.id] = true;
        });
        loadNextPage(firstResponse);
      });
      return result;
    } // loadAllPages
  };
}]).

factory('eventId', ['$rootElement', function($rootElement) {
  return $rootElement.data('event-id');
}]).

factory('involvementId', ['$rootElement', function($rootElement) {
  return $rootElement.data('involvement-id');
  // TODO set in $rootScope too?
}]).

factory('Events', ['Restangular', function(Restangular) {
  return {
    eventResource: function(eventId) {
      return Restangular.one('events', eventId);
    }
  };
}]).

factory('Involvements', ['Events', 'eventId', function(Events, eventId) {
  return {
    involvementResource: function(involvementId) {
      return Events.eventResource(eventId).one('involvements', involvementId);
    },
    get: function(involvementId) {
      return this.involvementResource(involvementId).get().$object;
    }
  };
}]).

factory('Shifts', ['Restangular', 'PaginatedLoader', 'Events', 'eventId',
    function(Restangular, PaginatedLoader, Events, eventId) {
  var shiftsResource = Events.eventResource(eventId).all('shifts');
  return {
    listForPositions: function(positionIds) {
      // sort to increase chances of cache hits
      var params = {'position_id[]': _.sortBy(positionIds)};
      return PaginatedLoader.loadAllPages(shiftsResource, params);
    }
  };
}]).

factory('Attendees', ['Restangular', 'Events', 'Involvements', 'eventId',
    function(Restangular, Events, Involvements, eventId) {
  var eventResource = Events.eventResource(eventId);
  var attendeeResource = eventResource.all('attendees');
  return {
    resourceForInvolvement: function(involvementId) {
      return Involvements.involvementResource(involvementId).all('attendees');
    },
    listForInvolvement: function(involvementId) {
      return this.resourceForInvolvement(involvementId).getList().$object;
    },
    create: function(involvementId, slotId, callback, errback) {
      var params = {slot_id: slotId};
      var promise = this.resourceForInvolvement(involvementId).post(params);
      promise.then(callback, errback);
      return promise;
    },
    destroy: function(attendeeId, callback, errback) {
      eventResource.one('attendees', attendeeId).remove().then(callback, errback);
    }
  };
}]);
