
/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , user = require('./routes/user')
  , http = require('http')
  , path = require('path')
  , common = require('./common/common.js')
  , mongo = common.mongo;
 // var MongoStore = require('connect-mongo');
 // var settings = require('./settings');
 var parseCookie = require('connect').utils.parseSignedCookie;
 var MemoryStore = require('connect/lib/middleware/session/memory');
 var sio = require('socket.io');

var myParser = require('./parser.js').parseCookie;

var usersWS = {};
var storeMemory = new MemoryStore({
  reapInterval: 60000 * 10
});

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');
app.use(express.favicon());
app.use(express.logger('dev'));
//app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.cookieParser());
app.use(express.session({
  secret: 'msbhb5',
  store: storeMemory
  // store: new MongoStore({
  //   db: settings.db
  // })
}));
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));

//=====================配置socket.io=========================

app.get('/', function(req, res) {
  //需要补上相应的逻辑
});

app.get('/todo/stats/init',function(req, res, next){
  //user.init(req, res, next);
  console.log('sadf');
  res.end();
});

app.post('/todo/stats/collect/:id', function(req, res, next){
	user.collect(req, res, next);
 });

app.get('/todo/stats/wave/:name', function(req, res) {
  req.session.name = req.params.name;
  res.end();  
});

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

// mongo.init('todo', 'localhost');
// mongo.open();

//这里跟标准的Express3.x写法不同，注意
var server = http.createServer(app);
var io = sio.listen(server);

server.listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
  console.log(new Date().getTime());
});



io.set('authorization', function(handshakeData, callback) {
  //通过客户端cookie字符串来获取其session数据
  //console.log(handshakeData.headers);
  //handshakeData.cookie = handshakeData.headers.cookie.split('=');

  var connect_sid = myParser(handshakeData.headers.cookie).substring(4, 28);
  if(connect_sid) {
    storeMemory.get(connect_sid, function(error, session) {
      if(error){
        callback(error.message, false);
      }else {
        handshakeData.session = session;
        callback(null, true);
      }
    });
  }else {
    callback('nosession');
  }
});

io.sockets.on('connection', function(socket) {
  //console.log(socket.handshake);
  var session = socket.handshake.session;
  var name = session.name;
  usersWS[name] = socket;

  console.log(socket);
  console.log(socket.handshake);

  socket.on('welcom', function(data) {
    var target;
    target = usersWS['msbhb1'];
    target.emit('himessage', data);
  });

  socket.on('msg', function(message){
    console.log(message);
  });
  //广播给所有用户
  //socket.broadcast.emit('user connected');

  //广播给全体客户端
  // io.sockets.emit('all users');
});
