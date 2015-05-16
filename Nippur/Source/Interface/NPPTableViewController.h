/*
 *	NPPTableViewController.h
 *	Copyright (c) 2011-2015 db-in. More information at: http://db-in.com
 *	
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

// Table Keys.
#define kNPPTableBackground			@"background"
#define kNPPTableBounces			@"bounces"
#define kNPPTableEditable			@"editable"
#define kNPPTableSections			@"sections"
#define kNPPTableStyle				@"style"
#define kNPPTableSeparatorStyle		@"separatorStyle"
#define kNPPTableCellClass			@"cellClass"
#define kNPPTableCellHeight			@"cellHeight"
#define kNPPTableCellProperties		@"cellProperties"

// Section Keys.
#define kNPPTableHeader				@"header"
#define kNPPTableFooter				@"footer"
#define kNPPTableCells				@"cells"

// Shared by Table or Cell's methods.
#define kNPPTableAction				@"action"
#define kNPPTableSelection			@"selection"
#define kNPPTableGestureSwipe		@"gestureSwipe"
#define kNPPTableGesturePress		@"gesturePress"

// Common to any Section/Cell type.
#define kNPPTableClass				@"class"
#define kNPPTableHeight				@"height"
#define kNPPTableProperties			@"properties"

typedef NS_OPTIONS(NSUInteger, NPPGesture)
{
	NPPGestureNone				= 0,
	NPPGestureSwipe				= 1 << 0,
	NPPGestureLongPress			= 1 << 1,
	NPPGestureDoubleTap			= 1 << 2,
};

typedef NS_OPTIONS(NSUInteger, NPPGestureKind)
{
	NPPGestureKindUnknown,
	NPPGestureKindDefault,
	NPPGestureKindLeft,
	NPPGestureKindRight,
	NPPGestureKindUp,
	NPPGestureKindDown,
};

@protocol NPPTableViewItem <NSObject>

@required
+ (float) heightForItem;

@end

@interface NPPTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
@protected
	UITableView					*_tableView;
	NSIndexPath					*_selectedIndexPath;
	NSMutableArray				*_selectedIndexPaths;
	
@private
	NSMutableDictionary			*_data;
	NSMutableDictionary			*_dataState;
	id							_delegate;
	id <UIScrollViewDelegate>	_scrollDelegate;
	NPP_ARC_UNSAFE UIView		*_customView;
	BOOL						_lockSelection;
	NPPGesture					_gestures;
	BOOL						_isClearing;
	BOOL						_isPreventingInteraction;
}

/*!
 *					The delegate will receive the callbacks from the cells.
 *					If no delegate is set, the "self" will be used as delegate.
 */
@property (nonatomic, NPP_ASSIGN) id delegate;

/*!
 *					This delegate is specific to the scroll movements in the table.
 *					All the UIScrollViewDelegate methods will be called on the target if implemented.
 */
@property (nonatomic, NPP_ASSIGN) id <UIScrollViewDelegate> scrollDelegate;

/*!
 *					The table view instance.
 */
@property (nonatomic, NPP_RETAIN) UITableView *tableView;

/*!
 *					Setting the data will automatically reload the table.
 */
@property (nonatomic, NPP_COPY) NSDictionary *data;

/*!
 *					Returns the last selected index path. If multiple cells was selected this method will
 *					return only the last one.
 */
@property (nonatomic, NPP_RETAIN) NSIndexPath *selectedIndexPath;

/*!
 *					Returns the current selected cells.
 */
@property (nonatomic, readonly) NSMutableArray *selectedIndexPaths;

- (id) initWithView:(UIView *)aView file:(NSString *)plist target:(id)delegate;
- (id) initWithView:(UIView *)aView data:(NSDictionary *)dictionary target:(id)delegate;

// Special gestures.
- (void) tableGesture:(NPPGesture)gesture willStartAtIndexPath:(NSIndexPath *)indexPath;
- (void) tableGesture:(NPPGesture)gesture didEndAtIndexPath:(NSIndexPath *)indexPath;

// Data manipulations.
//- (void) insertRow:(NSInteger)row inSection:(NSInteger)section completion:(NPPBlockVoid)block;
//- (void) deleteRow:(NSInteger)row inSection:(NSInteger)section completion:(NPPBlockVoid)block;
//- (void) deleteSection:(NSInteger)section completion:(NPPBlockVoid)block;
- (void) updateCellValue:(id)object key:(NSString *)key forRow:(NSInteger)row inSection:(NSInteger)section;
- (void) updateCellData:(NSDictionary *)cellData forRow:(NSInteger)row inSection:(NSInteger)section;
- (void) updateTable;

// Cell retrievers.
- (UITableViewCell *) cellSelected;
- (UITableViewCell *) cellForRow:(NSInteger)row inSection:(NSInteger)section;
- (NSDictionary *) cellDataForRow:(NSInteger)row inSection:(NSInteger)section;

// Selections.
- (void) preventCurrentInteraction;
- (void) markCell:(NSIndexPath *)indexPath; // Does not perform select action.
- (void) selectCell:(NSIndexPath *)indexPath animated:(BOOL)animated; // Perform select action.
- (void) deselectCell:(NSIndexPath *)indexPath animated:(BOOL)animated; // Perform deselect action.

// Global settings.
+ (void) defineCellClassName:(NSString *)cellClassName;

@end

@interface NPPDataManager(NPPTableData)

+ (NSMutableDictionary *) tableDataWithSections:(NSUInteger)sections rows:(NSUInteger)rows;

@end