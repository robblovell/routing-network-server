// Generated by CoffeeScript 1.10.0
(function() {
  var Redis, RedisRepository, iRepository,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Redis = require('ioredis');

  iRepository = require('./iRepository');

  RedisRepository = (function(superClass) {
    extend(RedisRepository, superClass);

    function RedisRepository(config) {
      this.config = config;
      if (this.config.url == null) {
        this.config.url = 'redis://127.0.0.1:6379/1';
      }
      this.redis = new Redis(this.config.url);
      this.buffer = null;
    }

    RedisRepository.prototype.find = function(query, callback) {
      return this.redis.get(query, callback);
    };

    RedisRepository.prototype.get = function(example, callback) {
      return this.redis.get(example.id, callback);
    };

    RedisRepository.prototype.add = function(obj) {
      var result;
      if ((this.buffer != null)) {
        return this.buffer.set(id, JSON.stringify(obj));
      } else {
        result = this.redis.set(id, JSON.stringify(obj));
        return callback(null, result);
      }
    };

    RedisRepository.prototype.set = function(id, obj, callback) {
      var result;
      if ((this.buffer != null)) {
        return this.buffer.set(id, JSON.stringify(obj));
      } else {
        result = this.redis.set(id, JSON.stringify(obj));
        return callback(null, result);
      }
    };

    RedisRepository.prototype["delete"] = function(id) {
      throw new Error("not implemented");
    };

    RedisRepository.prototype.pipeline = function() {
      return this.buffer = this.redis.pipeline();
    };

    RedisRepository.prototype.exec = function(callback) {
      this.buffer.exec(callback);
      return this.buffer = null;
    };

    return RedisRepository;

  })(iRepository);

  module.exports = RedisRepository;

}).call(this);

//# sourceMappingURL=RedisRepository.js.map
