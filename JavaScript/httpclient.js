exports.requestJSON = function(url, delegate) {
	Ti.API.info('HTTP request for JSON object from: ' + url);
	var request = Titanium.Network.createHTTPClient({
		autoEncodeUrl : false
	});
	request.open('GET', url);

	// we want le JSON.
	request.setRequestHeader('Accept', 'application/json');
	request.setRequestHeader('Content-Type', 'application/json; charset=utf-8');

	request.onload = function() {
		if(request.readyState == request.DONE) {
			if(request.status == 200 && request.responseText != null) {
				// TODO: json validate
				try {
					delegate.requestFinished(JSON.parse(this.responseText));
				} catch(SyntaxError) {
					Ti.API.log(SyntaxError);
					delegate.displayMessage('Fout bij het verwerken van de gegevens');
				}
				return this.responseText;
			} else {
				Ti.API.log('request error: status: ' + request.status + '\n responseText: ' + request.responseText);
				delegate.displayMessage('Fout bij het ophalen van de gegevens');
				return;
			}
		}
	};
	request.send();
}
