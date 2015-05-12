/*
 *	NPPTableViewController.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 3/5/12.
 *	Copyright 2012 db-in. All rights reserved.
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

typedef enum
{
	NPPGestureNone				= 0,
	NPPGestureSwipe				= 1 << 0,
	NPPGestureLongPress			= 1 << 1,
	NPPGestureDoubleTap			= 1 << 2,
} NPPGesture;

typedef enum
{
	NPPGestureKindUnknown,
	NPPGestureKindDefault,
	NPPGestureKindLeft,
	NPPGestureKindRight,
	NPPGestureKindUp,
	NPPGestureKindDown,
} NPPGestureKind;

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