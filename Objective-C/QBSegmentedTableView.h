//
//  QBSegmentedTableView.h
//  QApp
//
//  Created by Wolfert de Kraker on 8/15/11.
//  Copyright 2011 ~. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBTableViewDelegate.h"
#import "QBTableCell.h"
#import "QBLib.h"

@interface QBSegmentedTableView : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate>{
    id<QBTableViewDelegate> _qDelegate;
    NSMutableArray          * _contentArray;
    NSMutableArray          * _headerArray;
    NSMutableArray          * __unsafe_unretained _content;
    NSMutableArray          * _indexArray;
    UITextField             * _activeField;
    BOOL _autoSort;
    BOOL _indexed;
    BOOL _variableRowHeights;
    BOOL _keyboardShown;
}

@property (nonatomic, unsafe_unretained) id<QBTableViewDelegate> QDelegate;
@property (nonatomic, unsafe_unretained) NSMutableArray * content;
@property (nonatomic, readonly)  NSMutableArray * contentArray;
@property (nonatomic) BOOL autoSort;
@property (nonatomic) BOOL indexed;
@property (nonatomic) BOOL variableRowHeights;

- (NSMutableArray*)contentArray;
- (void)registerForKeyboardNotifications;
@end
