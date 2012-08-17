//
//  QBSegmentedTableView.m
//  QApp
//
//  Created by Wolfert de Kraker on 8/15/11.
//  Copyright 2011 ~. All rights reserved.
//

#import "QBSegmentedTableView.h"
#import "QBDataContainer.h"

@implementation QBSegmentedTableView

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///
/// QBSegmentedTableView wordt gebruikt om bijvoorbeeld de detailRaportages weer te geven.
/// Als je een string toevoegd aan de tabel zal hij geen cell laten maar een header en een nieuw 
/// Segment starten met cellen. 
///
////////////////////////////////////////////////////////////////////////////////////////////////////////////


@synthesize content     = _content;
@synthesize contentArray= _contentArray;
@synthesize autoSort    = _autoSort;
@synthesize QDelegate   = _qdelegate;
@synthesize indexed     = _indexed;
@synthesize variableRowHeights = _variableRowHeights;

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark initialization
- (id) initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        
        _headerArray = [[NSMutableArray alloc] init];
        _contentArray= [[NSMutableArray alloc] init];
        _autoSort    = NO;
        _indexed     = NO;
        _variableRowHeights = NO;
        

    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    
    
    if (self.tableView.style == UITableViewStyleGrouped && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        UIView * bgView = [[UIView alloc] initWithFrame:self.view.frame];
        bgView.backgroundColor = tableviewAchtergrond;
        bgView.alpha = 0.3;
        [self.tableView setBackgroundView:bgView];
    }

}

- (void)registerForKeyboardNotifications
{
    // Register notification when the keyboard will be show
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    // Register notification when the keyboard will be hide
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _keyboardShown = FALSE;
}

-(void) keyboardWillShow:(NSNotification *)note
{
    // Get the keyboard size
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    
    // Detect orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.tableView.frame;
    
    // Start animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    CGFloat tabBarHeight = [[QBDataContainer sharedDataContainer].tbc tabBar].frame.size.height;
    
    // Reduce size of the Table view 
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        frame.size.height -= (keyboardBounds.size.height - tabBarHeight);
    else 
        frame.size.height -= (keyboardBounds.size.width - tabBarHeight);
    

    
    
    // Apply new size of table view
    self.tableView.frame = frame;
    
    // Scroll the table view to see the TextField just above the keyboard
    if (_activeField)
    {
        CGRect textFieldRect = [self.tableView convertRect:_activeField.bounds fromView:_activeField];
        [self.tableView scrollRectToVisible:textFieldRect animated:NO];
    }
    
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note
{

    // Get the keyboard size
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    
    // Detect orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.tableView.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    CGFloat tabBarHeight = [[QBDataContainer sharedDataContainer].tbc tabBar].frame.size.height;

    // Reduce size of the Table view 
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        frame.size.height += (keyboardBounds.size.height - tabBarHeight);
    else 
        frame.size.height += (keyboardBounds.size.width - tabBarHeight);

    // Apply new size of table view
    self.tableView.frame = frame;
    
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _activeField= textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    _activeField= nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield {
    [textfield resignFirstResponder];
    return YES;
}

// Wants UITablecells and NSStrings for breakfast!!!
- (void) setContent:(NSMutableArray *)content {
    
    // Het kan zijn dat er nog oude content was, verwijder deze dan eerst voordat je de datasource er opnieuw inzet.
    // Misschien een idee om een 'BOOL needsUpdate' property te zetten ofzo?
    if (_headerArray) [_headerArray removeAllObjects];
    if (_contentArray) [_contentArray removeAllObjects];
            
  
    if (_indexed) _indexArray = [[NSMutableArray alloc] init];
    
    _content = content;
    
    if (_autoSort) {
        
        for(char  c=0;c<='Z';c++)
        {
            NSMutableArray * lv_tempArr = [[NSMutableArray alloc] init];
            
            for (NSObject *item in _content) {
                if([item isKindOfClass:[UITableViewCell class]]) {
                    // Cell
                    if(((UITableViewCell*)item).textLabel.text)
                        if ([((UITableViewCell*)item).textLabel.text characterAtIndex:0] == c) {
                            [lv_tempArr addObject:item];
                        }
                    if ([item isKindOfClass:[QBTableInputCell class]]) {
                        if(((QBTableInputCell*)item).textField)((QBTableInputCell*)item).textField.delegate = self;
                    }
                } else {
                    // o.a. header maar die hoeft hier nog niet
                }
                

            }
            if([lv_tempArr count] >0)
            {
                [_headerArray addObject:[NSString stringWithFormat:@"%c",c]];
                if (_indexArray) [_indexArray addObject:[NSString stringWithFormat:@"%c",c]];
                [_contentArray addObject:lv_tempArr];
            }
        }  
    } else {
        
        NSMutableArray * lv_tempArr = [[NSMutableArray alloc] init];
        
        // -1 omdat de count van 1 tot x telt, terwijl de array op 0 start.
        //Voor deze forloop gekozen omdat je dan makkelijk kunt checken of je bij de laatste index bent aangekomen. 
        for(int i = 0; i <= [content count]-1; i++) {
            NSObject * obj = [content objectAtIndex:i];
            if ([obj isKindOfClass:[QBTableInputCell class]]) {
                if(((QBTableInputCell*)obj).textField)((QBTableInputCell*)obj).textField.delegate = self;
            }
            if ([obj isKindOfClass:[NSString class]]) {
                // Sectionheader
                [_headerArray addObject:obj];
                
                // Section content toevoegen
                if([lv_tempArr count]>0)[_contentArray addObject:[NSMutableArray arrayWithArray:lv_tempArr]];
                [lv_tempArr removeAllObjects];
            } else if ([obj isKindOfClass:[UITableViewCell class]]){
                
                // Cell toevoegen aan temp. array.
                [lv_tempArr addObject: obj];
            }
            
            //Bij de laatste index aangekomen. specifiek de array toevoegen anders mist de laatste section
            if (i == [content count]-1) {
                [_contentArray addObject:lv_tempArr];
            }
            
        }
        
    }
    self.tableView;
    [self.tableView reloadData];
}

- (NSMutableArray*) content {
    return _content;
}

- (void) setAutoSort:(BOOL)autoSort {
    _autoSort = autoSort;
}
- (BOOL) autoSort {
    return  _autoSort;
}

-(void) setIndexed:(BOOL)indexed {
    _indexed = indexed;
}
- (BOOL) indexed {
    return _indexed;
}

- (NSMutableArray*) contentArray {
    return _contentArray;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark tableView
//Sections:
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_headerArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_contentArray objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return  [_headerArray objectAtIndex:section];
}

//Index:
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _indexArray;
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [_indexArray indexOfObject:title];
}

//Content:
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (_variableRowHeights)
    {
        return  ((QBTableCell *) [[_contentArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]).customHeight;  
    }
    else 
    {
        return 45.0f; 
    }
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return [[_contentArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

// Action:
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QBTableCell * cell = [[_contentArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    //Cell wordt terug gegeven aan tableview houdende class, via protocol.
    if ([_qdelegate respondsToSelector:@selector(QBSegmentedTableView:didSelectItem:)]) {
        [_qdelegate QBSegmentedTableView:self didSelectItem:cell];
    } else {
        NSAssert([_qdelegate respondsToSelector:@selector(QBSegmentedTableView:didSelectItem:)], @"QDelegate did not implement the QBTableView Delegate correctly.");
    }
}

// Scrolling :
// Om onderstaande methodes te gebruiken hoef je alleen maar de methodes aan te maken in de class en natuurlijk de delegate te vullen
- (void) scrollViewDidScroll:(UIScrollView *)scrollView 
{
    if ([_qdelegate respondsToSelector:@selector(scrollViewDidScroll:)]) 
    {
        [_qdelegate performSelector:@selector(scrollViewDidScroll:) withObject:scrollView];
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_qdelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) 
    {
        [_qdelegate performSelector:@selector(scrollViewWillBeginDragging:) withObject:scrollView];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
