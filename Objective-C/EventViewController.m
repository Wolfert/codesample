//
//  EventViewController.m
//  iStager
//
//  Created by Wolfert de Kraker on 27-02-12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"


@implementation EventViewController

- (id) initWithEvent:(Event*) event {
	if ((self = [super init])) {
		_event = event;
		_contentArray = [[NSMutableArray alloc] init];
		_headerArray  = [[NSMutableArray alloc] init];
		self.title = _event.title;
	}
	return self;
}



- (void) viewDidLoad{
	[super viewDidLoad];

	CGRect f = self.view.frame;
    
	_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, f.size.width, f.size.height) style:UITableViewStyleGrouped];
	_table.delegate = self;
	_table.dataSource = self;
	[self.view addSubview: _table];

	self.navigationItem.rightBarButtonItem =  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																							 target:self
																							 action:@selector(share)] autorelease];
	
	[self buildContent];
}

- (void) buildContent {
	// header cell. (day/date/times/title/location/tags
	EventHeaderCell * ehc = [[EventHeaderCell alloc] init];
	NSDateFormatter * df = [[NSDateFormatter alloc] init];


	int weekday = [[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:_event.startTime] weekday];
	NSArray * weekDays = [NSArray arrayWithObjects:@"ZO", @"MA", @"DI", @"WO", @"DO", @"VRIJ", @"ZA", nil];
	[df setDateFormat:@"dd"];

	ehc.dayLabel.text = [NSString stringWithFormat:@"%@ %@/", [weekDays objectAtIndex:weekday-1], [df stringFromDate:_event.startTime]];
	// TODO: month name!
	[df setDateFormat:@"yyyy"];
	ehc.dateLabel.text = [NSString stringWithFormat:@"%@ %@", @"FEB", [df stringFromDate:_event.startTime]];
	
	
	ehc.titleLabel.text = _event.title;
	ehc.whereLabel.text = _event.subtitle;
	
	[df setDateFormat:@"HH:mm"];
	ehc.timesLabel.text = [NSString stringWithFormat:@"Open: %@u\nStart:  %@u\nEinde: %@u", [df stringFromDate:_event.doorsOpen], [df stringFromDate:_event.startTime],[df stringFromDate:_event.endTime]];
	[_contentArray addObject:[NSArray arrayWithObject:ehc]];
	[ehc release];
	[df release];
	
	// attached content cell : images/video/audio

	
	// content cell (webview rendering html type content)
	EventContentCell * ecc = [[EventContentCell alloc] initWithContent:_event.content.content];
	[_contentArray addObject:[NSArray arrayWithObject:ecc]];
	[ecc release];
	
	// share kit \o/
	EventFooterView * efv = [[EventFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
	efv.delegate = self;
	[efv addLocation];
	[efv addShare];
	[efv addAgenda];
	[_table setTableFooterView:efv];
	
	[_headerArray addObjectsFromArray:[NSArray arrayWithObjects:@"", @"", nil]];
	NSAssert([_headerArray count] == [_contentArray count], @"You sent an unequal number of headers & sections! The unholy child weeps the blood of virgins, and Russian hackers pwn your webapp!");
	[_table reloadData];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark event options

- (void) maps {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:
												[[NSString stringWithFormat: @"http://maps.google.nl/maps?q=%@", _event.location.formattedAddress] 
												 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (void) agenda {
	// Ask user for permission, come back when it has been given
	if (!_approval) {
		UIActionSheet * comfirm = [[UIActionSheet alloc] initWithTitle:@"Zet in agenda?" delegate:self cancelButtonTitle:@"Annuleren" destructiveButtonTitle:nil otherButtonTitles:@"Ok",nil];
		comfirm.delegate = self;
		[comfirm setActionSheetStyle:UIActionSheetStyleBlackTranslucent];	
		[comfirm showInView:self.view];
		return;
	}
	
    EKEventStore *eventStore = [[EKEventStore alloc] init];
	
    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
    event.title     = _event.title;
    event.startDate = _event.startTime;
    event.endDate   = _event.endTime;
	event.notes		= _event.location.formattedAddress;
	
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    NSError *err;
    [eventStore saveEvent:event span:EKSpanThisEvent error:&err]; 
	if(err == nil){
		UIAlertView * av = [[[UIAlertView alloc] initWithTitle:@"Succes" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
		[av show];
	}
	_approval = NO;
}


- (void) share
{

	// Create the item to share
	SHKItem *item = [SHKItem text:_event.title];
	
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
	[actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];	
	[actionSheet setTitle:@"Delen:"];
	[actionSheet showInView:self.view];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark actionsheet delegate methods
- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1)return;
	
	// persmission granted to add event to agenda.
	_approval = YES;
	[self agenda];
	[actionSheet release];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark tableview delegate methods
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return [_headerArray count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [_headerArray objectAtIndex:section];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[_contentArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[_contentArray objectAtIndex:section] count];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"selected row %d:%d", indexPath.section, indexPath.row);
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) return kCellHeight*2-30;
	return kCellHeight;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark memory
- (void) dealloc {
	[super dealloc];
	[_table release];
	[_contentArray release];
	[_headerArray release];
}
@end
