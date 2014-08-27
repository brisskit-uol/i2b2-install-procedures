{
	urlProxy: "index.php",
	urlFramework: "js-i2b2/",
	//-------------------------------------------------------------------------------------------
	// THESE ARE ALL THE DOMAINS A USER CAN LOGIN TO
	lstDomains: [
		{ name: "${domain.name}",
		  domain: "${domain.id}",
		  debug: true,
		  adminOnly: true,
		  urlCellPM: "${pm.getservices.address.used.by.proxy}"
		}
	]
	//-------------------------------------------------------------------------------------------
}
