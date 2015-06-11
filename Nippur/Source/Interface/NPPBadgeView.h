/*
 *	NPPBadgeView.h
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

#import "NPPPluginView.h"
#import "NPPPluginFont.h"
#import "NPPLabel.h"

/*!
 *					The badge view is a concrete view that can easily show badges in iOS style (red circle)
 *					with a white number).
 */
@interface NPPBadgeView : UIView
{
@private
	UIImageView				*_background;
	NPPLabel				*_labelNumber;
}

/*!
 *					The number that appears inside the circle.
 */
@property (nonatomic) int number;

/*!
 *					Initializes a new instance with a number in it.
 *
 *	@param			value
 *					The value inside the circle.
 *
 *	@result			A new instance.
 */
- (id) initWithNumber:(int)value;

/*!
 *					Returns an autoreleased new instance with a number in it.
 *
 *	@param			value
 *					The value inside the circle.
 *
 *	@result			An autoreleased instance.
 */
+ (id) badgeWithNumber:(int)value;

/*!
 *					Returns an autoreleased new instance with the Application Badge Number in it.
 *
 *	@result			An autoreleased instance.
 */
+ (id) badgeWithApplicationBadgeNumber;

@end