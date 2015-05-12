/*
 *	NPPTableViewCell.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 3/7/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPTableViewController.h"

@interface NPPTableViewCell : UITableViewCell <NPPTableViewItem>
{
@protected
	BOOL								_onTable;
	NSString							*_cellIdentifier;
	NSIndexPath							*_indexPath;
	NPP_ARC_ASSIGN NPPTableViewController	*_tableController;
	
	// Gestures.
	NPPGesture							_enabledGestures;
	NPPGesture							_currentGesture;
	NPPGestureKind						_currentGestureKind;
	BOOL								_isTouching;
	CGPoint								_startingPoint;
	CGPoint								_touchingPoint;
}

@property (nonatomic, readonly) float cellHeight;
@property (nonatomic, NPP_COPY) NSString *cellIdentifier;
@property (nonatomic, NPP_COPY) NSString *cellText;
@property (nonatomic, NPP_RETAIN) UIImage *cellIcon;
@property (nonatomic, NPP_COPY) NSIndexPath *indexPath;
@property (nonatomic, NPP_ASSIGN) NPPTableViewController *tableController;
@property (nonatomic) NPPGesture enabledGestures; // The enabled gestures for this cell.
@property (nonatomic) NPPGesture currentGesture; // The current gesture in progress.
@property (nonatomic) NPPGestureKind currentGestureKind; // The kind of the current gesture.

- (NSMutableDictionary *) reusableCellState;
- (void) reuseCellWithState:(NSMutableDictionary *)state;

// At the initialization time.
- (void) cellDidInit;

// At the first time the cell is added to a superview, that means, the layout is completed.
- (void) cellDidLoad;

- (void) defineFirstCell;
- (void) defineMiddleCell;
- (void) defineLastCell;

- (void) findGestureInTouches:(NSSet *)touches;

// Custom height for this cell.
+ (float) heightForItem;

@end