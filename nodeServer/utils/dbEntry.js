var common = require('../common/common.js');
var util    = common.util;
var mongo   = common.mongo;

exports.initEntry =  function initEntry(params,win) {
  mongo.coll('last',function(last){
    ['total','done','notdone'].forEach(function(kind){
      last.update(
        {id:params.id,kind:kind},
        {id:params.id,kind:kind,sec:0,val:0},
        {upsert:true},mongo.res(function(entry){
        util.debug('INIT:'+JSON.stringify(entry));
        }));
    })
  });
};

// params = {id:"a", time:UTC-millis, total:4, done:3}
exports.saveEntry = function saveEntry(id,params) {
  var sec = common.timesec(params.time);
  params.notdone = params.total - params.done;

  ['total','done','notdone'].forEach(function(kind){
    var entry = {id:id,sec:sec,val:params[kind]};

    mongo.coll('last',function(last){
      var query = {id:entry.id,kind:kind,sec:{$lte:entry.sec}};

      last.findAndModify(
        query,
        [],
        {$set:{sec:entry.sec,val:entry.val}},
        {},

        mongo.res(function(lastentry){
          if( lastentry ) {
            var inc = entry.val - lastentry.val;

            mongo.coll('agg',function(agg){
              ['second','minute','hour','day'].forEach(function(period){
                var index = common[period](sec);

                agg.update(
                  {kind:kind,period:period,index:index},
                  {$inc:{val:inc}},
                  {upsert:true},
                  mongo.res()
                )
              })
            })
          }
        })
      )
    })
  })
}

