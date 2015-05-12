/*
 *	NPPActionMove.h
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

#import "NPPAction.h"

typedef enum
{
	NPPMoveTypeBy,
	NPPMoveTypeTo,
	NPPMoveTypeFrom,
	NPPMoveTypeFromTo,
} NPPMoveType;

typedef float (*NPPEase)(float begin, float change, float time, float duration);

/*!
 *					<strong>(Internal only)</strong> Class cluster for #NPPAction#.
 */
@interface NPPActionMove : NPPAction
{
@protected
	// Helpers
	NSMutableDictionary			*_tracker;
	NPPEase						_easingFunc;
	
	// Structure
	NSString					*_key;
	float						_from;
	float						_to;
	NPPMoveType					_type;
}

- (void) setKey:(NSString *)key from:(float)fromValue to:(float)toValue type:(NPPMoveType)type;

@end