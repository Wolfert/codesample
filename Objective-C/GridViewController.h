//
//  GridViewController.h
//  iStager
//
//  Created by Wolfert de Kraker on 20-02-12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "EventViewController.h"
#import "EventParser.h"
#import "EventButton.h"




@interface GridViewController : UIViewController <UIScrollViewDelegate, NSXMLParserDelegate, UIScrollViewDelegate> {
	UIScrollView	* scrollView;
	EventParser		* parser;
	NSMutableArray	* eventArray;
	UIPageControl	* pg;
	
	int numRows,numCols;
	int rows, cols, pageCount;
	CGFloat rowHeight, colHeight, xPos, yPos, xMargin, yMargin;
}

@property (nonatomic, retain) IBOutlet UIScrollView * scrollView;

- (void) parseXML;
- (void) gridIt;
- (void) addPage;
- (BOOL) isActive;
- (void) calculateGridMargins;
- (void) pushController: (UIViewController*) controller
         withTransition: (UIViewAnimationTransition) transition;

@end


