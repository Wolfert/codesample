//
//  EventViewController.h
//  iStager
//
//  Created by Wolfert de Kraker on 27-02-12.


#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

#import "EventHeaderCell.h"
#import "EventContentCell.h"
#import "EventFooterView.h"
#import "Event.h"
#import "SHK.h"



@interface EventViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	Event * _event;
	BOOL    _approval;
	UITableView * _table;
	NSMutableArray * _contentArray;
	NSMutableArray * _headerArray;
	UIToolbar	* _toolbar;
}


- (id) initWithEvent:(Event*) event;
- (void) buildContent;

- (void) maps;
- (void) agenda;
- (void) share;
@end
