//
//  QBLib.h
//  
//
//  Created by Wolfert de Kraker on 5/5/11.
//  Copyright ~. All rights reserved.
//


// 

/*
 Utility class, contains most UI components, macro's & style definitions
*/


// Utilities:
#import "QBExceptionHandler.h"
#import "QBDataContainer.h"
#import "QBLocalized.h"
#import "QBStringUtils.h"
#import "QBCallConfirm.h"
#import "QBLoadScreen.h"
#import "SHKActivityIndicator.h"
#import "QBSelector.h"
#import "QBStyle.h"

// Network:
#import "QBAsyncConnection.h"
#import "StringEncryption.h"

//Table items
#import "QBTableInputCell.h"
#import "QBTableSliderCell.h"
#import "QBTableGrayCell.h"
#import "QBTableGroupCell.h"
#import "QBTableThreeLabelText.h"
#import "QBTableCell.h"
#import "QBTableCheckBoxCell.h"
#import "QBCreateTableItems.h"

// Lists
#import "QBListController.h"
#import "QBLib.h"
#import "QBListCell.h"

// Controllers
#import "VngController.h"
#import "IncController.h"



//Data models:
#import "SvcDta.h"
#import "OpnTblType.h"

// UI elements:
#import "QBGridView.h"
#import "QBGridItem.h"
#import "QBGeneralViewObjects.h"
#import "QBButtons.h"
#import "QBSegmentedTableView.h"
#import "QBActionSheet.h"

// Ipad Utils:
#import "IpadPopViewController.h"

//Delegates:
#import "QBConnectionDelegate.h"

// - String utils:
#define QBEscape(string) [QBStringUtils escape:string]
#define QBUnescape(string) [QBStringUtils unescape:string]
#define QBFormatNumber(number) [QBStringUtils formatTelehponeNumber:number]
#define QBCheckNullCastString(string) [QBStringUtils unescape:string]
#define QBCheckNullAndTrim(string) [QBStringUtils checkNullandTrim:string]
#define QBGetIconFromType(int)[QBButton getIconName:int]
#define isEmpty(thing) [QBStringUtils isEmpty:thing];

// - Image utils:
#import "QBImagePicker.h"
#import "QBHandTekening.h"

// -  Color utils:
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]


// -  Tiny network indicatior in status bar
#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO


// -  Localisation
#define QBLocalize(key) [QBLocalized accesDict:key]


// - UIView:
#define QBLandscape ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)


// - View.frame tools:
#define QFrameWxH(view) NSLog(@"%f x %f", view.frame.size.width, view.frame.size.height);
#define QFrameXxY(view) NSLog(@"%f x %f", view.frame.origin.x, view.frame.origin.y);

#define QBoundsWxH(view) NSLog(@"%f x %f", view.bounds.size.width, view.bounds.size.height);
#define QBoundsXxY(view) NSLog(@"%f x %f", view.bounds.origin.x, view.bounds.origin.y);

// - Memory tools:
#define QBNilRelease(_pointer) {[_pointer release]; _pointer = nil; }


// Selector test
#define QBSelector(_instance, _selector) {[QBSelector instance:_instance performSelector:_selector];}
#define QBSelectorObj(_instance, _selector, _obj) {[QBSelector instance:_instance performSelector:_selector withObject:_obj];}

