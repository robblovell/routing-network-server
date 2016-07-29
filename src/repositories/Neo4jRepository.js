// Generated by CoffeeScript 1.10.0
(function() {
  var async, iGraphRepository, request;

  async = require('async');

  request = require('superagent');

  iGraphRepository = require;

  module.exports = iGraphRepository = (function() {
    function iGraphRepository(config) {
      this.config = config;
      this.buffer = null;
    }

    iGraphRepository.prototype.find = function(query, callback) {};

    iGraphRepository.prototype.get = function(id, callback) {};

    iGraphRepository.prototype.add = function(json, callback) {
      var make;
      make = function(json) {};
      if ((this.buffer != null) || (callback == null)) {
        this.buffer.push(make(json));
      } else {
        throw new Error('not implemented');
      }
    };

    iGraphRepository.prototype.set = function(id, json, callback) {
      var make;
      make = function(id, json) {};
      if ((this.buffer != null) || (callback == null)) {
        this.buffer.push(make(id, json));
      } else {
        throw new Error('not implemented');
      }
    };

    iGraphRepository.prototype["delete"] = function(id) {};

    iGraphRepository.prototype.pipeline = function() {
      return this.buffer = [];
    };

    iGraphRepository.prototype.exec = function(callback) {
      return async.parallelLimit(this.buffer, 10, (function(_this) {
        return function(error, results) {
          if ((error != null)) {
            console.log("Error:" + error);
          }
          return _this.buffer = null;
        };
      })(this));
    };

    return iGraphRepository;

  })();

}).call(this);

//# sourceMappingURL=Neo4jRepository.js.map