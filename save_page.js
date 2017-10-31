var system = require('system');
var page = require('webpage').create();

page.open(system.args[1], function()
	  {
	      window.setTimeout(function () {
		  console.log(page.title);
		  phantom.exit();
	      }, 1000);
	  });
