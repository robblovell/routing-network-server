// Generated by CoffeeScript 1.10.0
(function() {
  var Importer, config, importer;

  Importer = require('./NodeImporter');

  config = {
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

  config.nodeType = 'LtlCode';

  config.nodeIdName = '';

  importer = new Importer(config);

  module.exports = importer;

}).call(this);

//# sourceMappingURL=importLtlCodes.js.map
