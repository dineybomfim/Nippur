/*
 *	NPPPluginArray.h
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

#import "NPPRuntime.h"
#import "NPPFunctions.h"

/*!
 *					Utils package to the basic array object.
 */
@interface NSArray(NPPArray)


/*!
 *					Performs a selector in all items.
 *
 *	@param			selector
 *					The selector to be performed.
 */
- (void) performSelectorInAllItems:(SEL)selector;

/*!
 *					Returns the most repeated item in this collection. If two or more items have the same
 *					repeat count, only the first one will be returned.
 *
 *	@result			The item it self.
 */
- (id) mostRepeatedItem;

@end

/*!
 *					Utils package to the mutable array object.
 */
@interface NSMutableArray(NPPArray)

/*!
 *					Adds an object once. This method uses #isEqual:# method to compare two items.
 *
 *	@param			anObject
 *					The object to add once.
 */
- (void) addObjectOnce:(id)anObject;

/*!
 *					Acts as the #addObjectOnce:#, but looping on an array.
 *
 *	@param			otherArray
 *					An array with items to add once.
 */
- (void) addObjectsOnceFromArray:(NSArray *)otherArray;

@end