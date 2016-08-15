cleanupAndCollateWarehouses = (warehouses, zips) ->
    flags = ['isSeller','isSweepable','IsBDWP','IsResupplier','IsCustomerPickup','IsSatellite']
    for warehouse in warehouses
        for flag in flags
            if flag == -1 || flag == true || flag == 1 || flag == '1' || flag == '-1' || flag.toUpperCase() == 'TRUE'

                warehouse[flag] = true
            else
                warehouse[flag] = false

        zip = warehouse['PostalCode'].substring(0,3)
        matches = zips.filter(( obj ) -> return obj.zip3 == zip)
        if (matches.length > 0)
            zip = matches[0]
            warehouse.zip3 = zip.zip3
            warehouse.lat = zip.latitude
            warehouse.lon = zip.longitude
            warehouse.haszip = true
        else
            warehouse.haszip = false


    # make a list of BDWP warehouses
    bdwps = []
    for warehouse in warehouses
        if warehouse.IsBDWP or warehouse.IsResupplier
            bdwps.push(warehouse)
    resuppliers = []
    for warehouse in warehouses
        if warehouse.IsResupplier
            resuppliers.push(warehouse)

    # make a list of seller warehouses
    sellers = []
    for warehouse in warehouses
        if warehouse.isSeller
            sellers.push(warehouse)
    sweepers = []
    for warehouse in warehouses
        if warehouse.isSweepable
            sweepers.push(warehouse)
    satellites = []
    for warehouse in warehouses
        if warehouse.IsSatellite
            satellites.push(warehouse)

    return { bdwps:bdwps,resuppliers:resuppliers, sellers:sellers, sweepers:sweepers, satellites:satellites, warehouses:warehouses}

module.exports = cleanupAndCollateWarehouses
