/*
 *	NPPTableViewCell.h
 *	Copyright (c) 2011-2015 db-in. More information at: http://db-in.com/nippur
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