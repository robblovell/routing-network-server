// Generated by CoffeeScript 1.10.0
(function() {
  var Builder, Papa, async, cleanupAndCollateWarehouses, fs, geodist, iImport, math, papaConfig,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

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
      this.buildWarehousesToZips = bind(this.buildWarehousesToZips, this);
      this.wireupWarehousesToZips = bind(this.wireupWarehousesToZips, this);
    }

    Builder.prototype.setRepo = function(repo) {
      return this.repo = repo;
    };

    Builder.prototype.wireupWarehousesToZips = function(zips, warehouses, sourceKind, callback) {
      var i, id1, id2, len, matches, obj, params, warehouse, warehousezip3, zip;
      this.repo.pipeline();
      for (i = 0, len = warehouses.length; i < len; i++) {
        warehouse = warehouses[i];
        id1 = warehouse.id;
        warehousezip3 = warehouse.PostalCode.substring(0, 3);
        matches = zips.filter(function(obj) {
          return obj.zip3 === warehousezip3;
        });
        if (matches.length < 1) {
          console.log("ERROR:: Warehouse missing postal code: " + warehousezip3 + "  code: " + warehouse.PostalCode);
          continue;
        } else if (matches.length > 1) {
          console.log("ERROR:: More than one zip found.");
        }
        zip = matches[0];
        id2 = zip.id;
        params = {
          sourcekind: sourceKind,
          sourceid: '' + id1,
          destinationkind: 'Zip',
          destinationid: '' + id2,
          kind: 'WAREHOUSEZIP',
          linkid: id1 + '_' + id2
        };
        obj = {
          kind: 'WAREHOUSEZIP',
          id: id1 + "_" + id2
        };
        this.repo.setEdge(params, obj);
      }
      console.log("finished");
      this.repo.exec((function(_this) {
        return function(error, result) {
          if ((error != null)) {
            console.log("error:" + result);
            callback(error, result);
          } else {
            callback(error, result);
          }
        };
      })(this));
    };

    Builder.prototype.buildWarehousesToZips = function(callback) {
      var filename;
      filename = './data/warehouses.csv';
      this.repo.find({
        type: "Zip"
      }, (function(_this) {
        return function(error, zips) {
          _this.repo.find({
            type: "Warehouse"
          }, function(error, warehouses) {
            _this.wireupWarehousesToZips(zips, warehouses, 'Warehouse', callback);
          });
          return _this.repo.find({
            type: "Seller"
          }, function(error, warehouses) {
            _this.wireupWarehousesToZips(zips, warehouses, 'Seller', callback);
          });
        };
      })(this));
    };

    return Builder;

  })(iImport);

  module.exports = Builder;

}).call(this);

//# sourceMappingURL=WarehousesToZips.js.map
