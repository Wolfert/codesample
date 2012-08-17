////////////////////////////////////////////////////////////////////////////////////
//
// block.js
//
////////////////////////////////////////////////////////////////////////////////////

function block(Event) {
	
	var S = require('stager/utils/utils');

	var view = Titanium.UI.createView({
		backgroundColor : S.style.list.row.backgroundColor,
		height : 44
	});

	var dateLabel = dateLabel();
	var titleLabel = titleLabel();
	view.add(dateLabel);
	view.add(titleLabel);
	view.add(eventImage());
	view.addEventListener('click', function() {
		highlight(1);
	});
	return view;

	// Parses the date and add the formatted style to the event object(we'll be needing it again).
	function dateLabel() {
		var months = S.months;
		var days = S.days;

		date = S.dateFromISO8601(Event.when.startTime);
		Event.when.day = days[date.getDay()] + '/\n' + date.getDate();
		Event.when.monthYear = months[date.getMonth()] + ' ' + date.getFullYear();
		Event.when.month = months[date.getMonth()];

		return dayLable = Titanium.UI.createLabel({
			text : Event.when.day,
			font : S.style.list.row.date.font,
			textAlign : 'right',
			color : S.style.list.row.date.color,
			width : 42,
			height : 'auto',
			top : 2,
			left : 5,
			touchEnabled : false,
		});
	};

	function titleLabel() {
		return Titanium.UI.createLabel({
			text : Event.title,
			font : S.style.list.row.title.font,
			textAlign : 'left',
			color : S.style.list.row.title.color,
			width : 220,
			height : 'auto',
			top : 2,
			left : 52,
			touchEnabled : false,
		});
	};

	// Returns an imageView. Either from attached image array index 0 or when null, a default image.
	function eventImage() {
		var imageArray = Event.media.images;

		// get the (m)obile version, it's smaller: 100x100px)
		function parseImageURL() {
			var href = imageArray[0].href;
			var pos0 = href.lastIndexOf('/') + 1;
			var pre = href.substring(0, pos0);
			var post = href.substring(pos0, href.length);
			href = pre + 'm' + post;
			return href;
		};

		return Titanium.UI.createImageView({
			image : imageArray.length != 0 ? parseImageURL() : 'stager/images/tags/event-concert.png',
			right : 0,
			top : 0,
			height : 44,
			width : 44,
		});
	};

	//Highlight color by default white.
	function highlight(state) {
		dateLabel.color = state ? '#fff' : S.style.list.row.date.color;
		titleLabel.color = state ? '#fff' : S.style.list.row.title.color;
		view.backgroundColor = state ? S.style.list.row.highlightColor : S.style.list.row.backgroundColor;
		if(state)
			setTimeout(function() {
				highlight(0);
			}, 300);
	};
};

module.exports = block; 