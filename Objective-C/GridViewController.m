//
//  GridViewController.m
//  iStager
//
//  Created by Wolfert de Kraker on 20-02-12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GridViewController.h"
#import "TouchXML.h"

@implementation GridViewController

@synthesize scrollView;

- (void) viewDidLoad {
	[super viewDidLoad];
	self.title = @"Events";
	
	// scrollView properties
	[scrollView setFrame:CGRectMake(0, 0, 320, 416)];
	[scrollView setPagingEnabled:YES];
	[scrollView setContentSize:scrollView.frame.size];
	[scrollView setBackgroundColor:RGB(145,145,145)];
	[scrollView setBounces:NO];
	[scrollView setDelegate:self];
	[scrollView setShowsHorizontalScrollIndicator:NO];
	[scrollView setShowsVerticalScrollIndicator:NO];
	
	// adding the dots (for page indication)
	pg = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 465, 320, 10)];
	[pg setNumberOfPages:1];

	// download & parse events from the feed
	[self parseXML];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController.view addSubview:pg];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[pg removeFromSuperview];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Load data


- (void) parseXML {
	// calculate grid metrics
	[self calculateGridMargins];
	
	// Parsen met touchXML, for xpath. https://github.com/TouchCode/TouchXML.git
	CXMLDocument * xmlDoc = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://worm.stager.nl/web/feeds/events"] 
															   encoding:NSUTF8StringEncoding 
																options:0 
																  error:nil];
	
	NSDictionary * mappings = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"http://www.w3.org/2005/Atom", @"http://schemas.google.com/g/2005", @"http://schemas.stager.nl/2011", nil]
														  forKeys:[NSArray arrayWithObjects:@"atom", @"gd", @"pro", nil]];
	
	NSArray * items = [xmlDoc nodesForXPath:@"atom:feed/atom:entry" namespaceMappings:mappings error:nil];	//@"//*[local-name() = 'entry']" 
	
	parser =  [[EventParser alloc] initWithMappings:mappings];
	EventButton * eb;
	for (CXMLElement * element in items) {
		
		Event * event = [parser parseEvent:element];
		[eventArray addObject:event];
		
		// recalculate next coordinates on grid 
		[self gridIt];
		
		// add event button
		eb = [EventButton buttonFromEvent:event atPoint:CGPointMake(xPos, yPos) delegate:self];
		[eb doLayout];
		[scrollView addSubview:eb];
		
		[event release];
	}
	[parser release];
 }

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Grid


- (void) calculateGridMargins {
	rows = 0;
	cols = 0;
	numCols = 3;
	numRows = 4;
	pageCount = 0;
	
	// calculate margins between buttons, depending on screensize and number of rows&cols.
	CGFloat w = scrollView.frame.size.width;
	CGFloat h = scrollView.frame.size.height;
	xMargin = (w-(numCols*BUTTON_WIDTH)) / (numCols+1);
	yMargin = (h-(numRows*BUTTON_HEIGHT)) / (numRows+1);
	yPos = yMargin;
}

- (void) gridIt {
	
	// calculates a new x and y position for a button on the grid.
	if (cols < numCols) {
		xPos =  ((BUTTON_WIDTH*cols)+(xMargin*cols))+(pageCount*scrollView.frame.size.width)+xMargin;
	} else {
		cols = 0;
		rows++;
		if (rows < numRows) {
			yPos = BUTTON_HEIGHT*rows+yMargin*rows+yMargin;
		} else {
			[self addPage];
			rows = 0;
			yPos = 0+yMargin;
		}
		xPos = xMargin+0+(pageCount*scrollView.frame.size.width);
	}
	cols++;
}


- (void) scrollViewDidScroll:(UIScrollView *)_scrollView {
	// Switch the indicator when more than 50% of the previous/next page is visible
	CGFloat pageWidth = _scrollView.frame.size.width;
	int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	pg.currentPage = page;
}

- (void) addPage {
	CGSize newSize = CGSizeMake((scrollView.contentSize.width+scrollView.frame.size.width), scrollView.frame.size.height);
	[scrollView setContentSize:newSize];
	pageCount++;
	[pg setNumberOfPages:pageCount+1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Action

- (void) didSelectEvent:(Event *)event {
	if (![self isActive]) return;
	EventViewController * evc = [[EventViewController alloc] initWithEvent:event];
	[self.navigationController pushViewController:evc animated:YES];
	[evc release];
}

- (BOOL) isActive {
	NSArray * vc = [[self navigationController] viewControllers];
	if (![[vc objectAtIndex:[vc count]-1]isEqual:self]) return NO;
	return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory


- (void) dealloc {
	[super dealloc];
	[eventArray release];
}
@end
