
/*
 * GET home page.
 */

// exports.index = function(req, res){
//   res.render('index', { title: 'Express' });
// };
var user = require('./user.js');

module.exports = function(app, handler) {

	app.get('/', function(req, res){
		res.send('Hi, this is front page~');
	});

	app.get('/users', function(req, res){
		res.send('Hi, this is user page');
	});

	app.post('/todo/stats/init',function(req, res){
  		user.init(req, res);
	});

	app.post('/todo/stats/collect/:id', function(req, res, next){
		console.log(req.params);
	});
};