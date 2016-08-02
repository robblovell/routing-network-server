// Generated by CoffeeScript 1.10.0
(function() {
  var Papa, ZipCodeImporter, async, fs, iImport,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  iImport = require('./iImport');

  Papa = require('babyparse');

  fs = require('fs');

  async = require('async');

  ZipCodeImporter = (function(superClass) {
    extend(ZipCodeImporter, superClass);

    function ZipCodeImporter(config) {
      this.config = config;
    }

    ZipCodeImporter.prototype.importKeyValue = function(filename, repo, callback) {
      var contents, data, have, id, j, k, len, len1, result, zipcode;
      contents = fs.readFileSync(filename, 'utf8');
      result = Papa.parse(contents, this.config);
      data = result.data;
      repo.pipeline();
      for (j = 0, len = data.length; j < len; j++) {
        zipcode = data[j];
        zipcode.zip3 = zipcode.zip.substring(0, 3);
        zipcode.type = "Zip";
      }
      have = [];
      for (k = 0, len1 = data.length; k < len1; k++) {
        zipcode = data[k];
        id = zipcode.zip3;
        if (!have[id]) {
          repo.set(id, zipcode, function(error, result) {
            if (error != null) {
              callback(error, null);
            }
          });
          have[id] = true;
        }
      }
      repo.exec(callback);
    };

    ZipCodeImporter.prototype["import"] = function(filename, repo, callback) {
      var addZipcodeFuncs, contents, data, i, j, len, makeAdd, result, zipcode;
      contents = fs.readFileSync(filename, 'utf8');
      result = Papa.parse(contents, this.config);
      data = result.data;
      makeAdd = function(zipcode) {
        return function(callback) {
          return repo.find(JSON.stringify({
            zip: zipcode.zip
          }), function(error, result) {
            if (result.body.length === 0) {
              repo.add(zipcode, function(error, result) {
                if ((error != null)) {
                  console.log(error);
                }
                callback(error, result);
              });
            } else {
              callback(error, result);
            }
          });
        };
      };
      addZipcodeFuncs = [];
      for (i = j = 0, len = data.length; j < len; i = ++j) {
        zipcode = data[i];
        addZipcodeFuncs.push(makeAdd(zipcode));
      }
      return async.parallelLimit(addZipcodeFuncs, 10, function(error, result) {
        if (error != null) {
          console.log(error);
        }
        callback(error, result);
      });
    };

    return ZipCodeImporter;

  })(iImport);

  module.exports = ZipCodeImporter;

}).call(this);

//# sourceMappingURL=ZipCodeImporter.js.map
