// Generated by CoffeeScript 1.10.0
(function() {
  var cleanupAndCollateWarehouses;

  cleanupAndCollateWarehouses = function(warehouses, zips) {
    var bdwps, flag, flags, i, j, k, l, len, len1, len2, len3, len4, len5, len6, m, matches, n, o, resuppliers, satellites, sellers, sweepers, warehouse, zip;
    flags = ['isSeller', 'isSweepable', 'IsBDWP', 'IsResupplier', 'IsCustomerPickup', 'IsSatellite'];
    for (i = 0, len = warehouses.length; i < len; i++) {
      warehouse = warehouses[i];
      for (j = 0, len1 = flags.length; j < len1; j++) {
        flag = flags[j];
        if (warehouse[flag] === -1 || warehouse[flag] === '-1' || warehouse[flag].toUpperCase() === 'TRUE' || warehouse[flag] === true || warehouse[flag] === 1 || warehouse[flag] === '1') {
          warehouse[flag] = true;
        } else {
          warehouse[flag] = false;
        }
      }
      zip = warehouse['PostalCode'].substring(0, 3);
      matches = zips.filter(function(obj) {
        return obj.zip3 === zip;
      });
      if (matches.length > 0) {
        zip = matches[0];
        warehouse.zip3 = zip.zip3;
        warehouse.lat = zip.latitude;
        warehouse.lon = zip.longitude;
        warehouse.haszip = true;
      } else {
        warehouse.haszip = false;
      }
    }
    bdwps = [];
    for (k = 0, len2 = warehouses.length; k < len2; k++) {
      warehouse = warehouses[k];
      if (warehouse.IsBDWP || warehouse.IsResupplier) {
        bdwps.push(warehouse);
      }
    }
    resuppliers = [];
    for (l = 0, len3 = warehouses.length; l < len3; l++) {
      warehouse = warehouses[l];
      if (warehouse.IsResupplier) {
        resuppliers.push(warehouse);
      }
    }
    sellers = [];
    for (m = 0, len4 = warehouses.length; m < len4; m++) {
      warehouse = warehouses[m];
      if (warehouse.isSeller) {
        sellers.push(warehouse);
      }
    }
    sweepers = [];
    for (n = 0, len5 = warehouses.length; n < len5; n++) {
      warehouse = warehouses[n];
      if (warehouse.isSweepable) {
        sweepers.push(warehouse);
      }
    }
    satellites = [];
    for (o = 0, len6 = warehouses.length; o < len6; o++) {
      warehouse = warehouses[o];
      if (warehouse.IsSatellite) {
        satellites.push(warehouse);
      }
    }
    return {
      bdwps: bdwps,
      resuppliers: resuppliers,
      sellers: sellers,
      sweepers: sweepers,
      satellites: satellites,
      warehouses: warehouses
    };
  };

  module.exports = cleanupAndCollateWarehouses;

}).call(this);

//# sourceMappingURL=CleanupAndCollateWarehouses.js.map