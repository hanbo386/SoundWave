
/*
 * GET users listing.
 */
var common = require('../common/common.js');
var dbEntry = require('../utils/dbEntry.js');
var initEntry = dbEntry.initEntry;
var saveEntry = dbEntry.saveEntry;

exports.list = function(req, res){
  res.send("respond with a resource");
};

exports.init = function(req, res, next){
	common.readjson(req, function(body){
		initEntry(body);
	});
	common.sendjson(res, {ok:true});
};

exports.collect = function(req, res, next){
	var id = req.params.id;
	common.readjson(req, function(body){
		saveEntry(id, body);
	});
	common.sendjson(res, {ok:true, id:id});
}