exports.parseCookie = function(cookie) {

	var mRes = cookie.split(';');
	for(var sub in mRes)
	{
		var res = mRes[sub].split('=');
		if(res[0] === 'connect.sid')
		{
			return res[1];
		}
		
	}
};