/*
 *	NPPTableViewCell.m
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

#import "NPPTableViewCell.h"

#import "NPPTableViewController.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_TOUCH_SWIPE_RANGE		25.0f
#define NPP_CELL_HEIGHT				48.0f

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPTableViewCell()

- (void) initializingCell;
- (void) findGestureInTouches:(NSSet *)touches;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPTableViewCell

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize cellIdentifier = _cellIdentifier, indexPath = _indexPath, tableController = _tableController,
			enabledGestures = _enabledGestures, currentGesture = _currentGesture,
			currentGestureKind = _currentGestureKind;

@dynamic cellHeight, cellText, cellIcon;

- (float) cellHeight { return self.height; }

- (NSString *) cellText { return self.textLabel.text; }
- (void) setCellText:(NSString *)value
{
	self.textLabel.text = nppS(value);
}

- (UIImage *) cellIcon { return self.imageView.image; }
- (void) setCellIcon:(UIImage *)value
{
	self.imageView.image = value;
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]))
	{
		[self initializingCell];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		UILabel *label;
		Class labelClass = [UILabel class];
		NSArray *array = self.contentView.subviews;
		for (label in array)
		{
			if ([label isKindOfClass:labelClass])
			{
				label.text = nil;
			}
		}
		
		[self initializingCell];
	}
	
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]))
	{
		[self initializingCell];
	}
	
	return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:identifier]))
	{
		self.cellIdentifier = identifier;
		self.height = [[self class] heightForItem];
		
		[self initializingCell];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializingCell
{
	[self cellDidInit];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (NSMutableDictionary *) reusableCellState
{
	return [NSMutableDictionary dictionary];
}

- (void) reuseCellWithState:(NSMutableDictionary *)state
{
	// Does nothing here, just in subclasses.
}

- (void) cellDidInit
{
	// Does nothing here, just in subclasses.
}

- (void) cellDidLoad
{
	// Does nothing here, just in subclasses.
}

- (void) defineFirstCell
{
	// Does nothing here, just in subclasses.
}

- (void) defineMiddleCell
{
	// Does nothing here, just in subclasses.
}

- (void) defineLastCell
{
	// Does nothing here, just in subclasses.
}

- (void) findGestureInTouches:(NSSet *)touches
{
	UITouch *touch;
	for (touch in touches)
	{
		if (_isTouching)
		{
			_currentGestureKind = NPPGestureKindUnknown;
			_touchingPoint = [touch locationInView:self];
			
			// Swipe gesture handler.
			if ((_enabledGestures & NPPGestureSwipe))
			{
				// Left.
				if (_startingPoint.x - _touchingPoint.x > NPP_TOUCH_SWIPE_RANGE)
				{
					_currentGestureKind = NPPGestureKindLeft;
					_currentGesture = NPPGestureSwipe;
				}
				// Right
				else if (_startingPoint.x - _touchingPoint.x < -NPP_TOUCH_SWIPE_RANGE)
				{
					_currentGestureKind = NPPGestureKindRight;
					_currentGesture = NPPGestureSwipe;
				}
			}
			
			if (_currentGestureKind != NPPGestureKindUnknown)
			{
				[_tableController tableGesture:_currentGesture willStartAtIndexPath:_indexPath];
				_isTouching = NO;
			}
		}
	}
}

+ (float) heightForItem
{
	return NPP_CELL_HEIGHT;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) didMoveToSuperview
{
	[super didMoveToSuperview];
	
	if (!_onTable)
	{
		_onTable = YES;
		[self cellDidLoad];
	}
}

- (NSString *) reuseIdentifier
{
	return _cellIdentifier;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	// Avoid processing if this cell doesn't respond to any gesture.
	if (_enabledGestures == NPPGestureNone)
	{
		return;
	}
	
	_isTouching = YES;
	
	UITouch *touch = nil;
	for (touch in touches)
	{
		_startingPoint = [touch locationInView:self];
		_touchingPoint = _startingPoint;
	}
	
	if (_enabledGestures & NPPGestureLongPress)
	{
		// Long press handler.
		double delayInSeconds = 0.5f;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
		{
			if (_isTouching)
			{
				_currentGesture = NPPGestureLongPress;
				[_tableController tableGesture:_currentGesture willStartAtIndexPath:_indexPath];
				_isTouching = NO;
			}
		});
	}
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	
	// Avoid processing if this cell doesn't respond to any gesture.
	if (_enabledGestures == NPPGestureNone)
	{
		return;
	}
	
	// Searches for cell gestures.
	[self findGestureInTouches:touches];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
	// Avoid processing if this cell doesn't respond to any gesture.
	if (_enabledGestures == NPPGestureNone)
	{
		return;
	}
	
	[_tableController tableGesture:_currentGesture didEndAtIndexPath:_indexPath];
	_currentGesture = NPPGestureNone;
	_startingPoint = CGPointZero;
	_touchingPoint = CGPointZero;
	_isTouching = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	
	// Avoid processing if this cell doesn't respond to any gesture.
	if (_enabledGestures == NPPGestureNone)
	{
		return;
	}
	
	// Searches for cell gestures.
	[self findGestureInTouches:touches];
	
	[_tableController tableGesture:_currentGesture didEndAtIndexPath:_indexPath];
	_currentGesture = NPPGestureNone;
	_startingPoint = CGPointZero;
	_touchingPoint = CGPointZero;
	_isTouching = NO;
}

- (void) dealloc
{
	nppRelease(_indexPath);
	nppRelease(_cellIdentifier);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
