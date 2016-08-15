// Generated by CoffeeScript 1.10.0
(function() {
  var Builder, Papa, async, cleanupAndCollateWarehouses, fs, geodist, iImport, math, papaConfig,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty,
    slice = [].slice;

  iImport = require('./../iImport');

  fs = require('fs');

  async = require('async');

  math = require('mathjs');

  geodist = require('geodist');

  fs = require('fs');

  cleanupAndCollateWarehouses = require('cleanupAndCollateWarehouses');

  Papa = require('babyparse');

  papaConfig = {
    delimiter: ",",
    newline: "",
    header: true,
    dynamicTyping: false,
    preview: 0,
    encoding: "UTF-8",
    worker: false,
    comments: false,
    step: void 0,
    download: false,
    skipEmptyLines: false,
    fastMode: false
  };

  Builder = (function(superClass) {
    extend(Builder, superClass);

    function Builder(config, repo1) {
      this.config = config;
      this.repo = repo1 != null ? repo1 : null;
      this.buildSweepsToWarehouses = bind(this.buildSweepsToWarehouses, this);
      this.wireupSweeps = bind(this.wireupSweeps, this);
    }

    Builder.prototype.setRepo = function(repo) {
      return this.repo = repo;
    };

    Builder.prototype.wireupSweeps = function(warehouses, callback) {
      var bdwp, closest, cost, distance, found, i, id1, id2, j, len, len1, obj, params, ref, ref1, sweeper;
      this.repo.pipeline();
      ref = warehouses.sweepers;
      for (i = 0, len = ref.length; i < len; i++) {
        sweeper = ref[i];
        id1 = sweeper.id;
        if (!sweeper.haszip) {
          continue;
        }
        found = null;
        closest = -1;
        ref1 = warehouses.bdwps;
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          bdwp = ref1[j];
          if (!bdwp.haszip) {
            continue;
          }
          distance = geodist({
            lat: parseInt(bdwp.lat),
            lon: parseInt(bdwp.lon)
          }, {
            lat: parseInt(sweeper.lat),
            lon: parseInt(sweeper.lon)
          });
          if (distance < closest || closest === -1) {
            closest = distance;
            found = bdwp;
          }
        }
        if (found != null) {
          id2 = found.id;
          cost = distance;
          params = {
            sourcekind: 'Seller',
            sourceid: '' + id1,
            destinationkind: 'Warehouse',
            destinationid: '' + id2,
            kind: 'SWEEP',
            linkid: id1 + '_' + id2
          };
          obj = {
            kind: 'SWEEP',
            cost: cost,
            id: id1 + "_" + id2
          };
          this.repo.setEdge(params, obj);
        } else {
          console.log("No warehouses found close to this sweeper, uses postal codes or the code is not assigned.");
        }
      }
      this.repo.exec((function(_this) {
        return function(error, result) {
          if ((error != null)) {
            console.log("error:" + result);
            callback(error, result);
          } else {
            console.log("finished");
            callback(error, result);
          }
        };
      })(this));
    };

    Builder.prototype.buildSweepsToWarehouses = function(callback) {
      this.repo.find({
        type: "Zip"
      }, (function(_this) {
        return function(error, zips) {
          return _this.repo.find({
            type: "Warehouse"
          }, function(error, warehouses) {
            return _this.repo.find({
              type: "Seller"
            }, function(error, sellers) {
              var collation;
              warehouses = slice.call(warehouses).concat(slice.call(sellers));
              collation = cleanupAndCollateWarehouses(warehouses, zips);
              _this.wireupSweeps(collation, callback);
            });
          });
        };
      })(this));
      return;
      return callback(null, true);
    };

    return Builder;

  })(iImport);

  module.exports = Builder;

}).call(this);

//# sourceMappingURL=SweepsToWarehouses.js.map