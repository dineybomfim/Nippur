/*
 *	NPPArray+NSArray.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 9/9/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPFunctions.h"

@interface NSArray(NPPArray)

- (void) performSelectorInAllItems:(SEL)selector;
- (id) mostRepeatedItem;

@end

@interface NSMutableArray(NPPArray)

- (void) addObjectOnce:(id)anObject;
- (void) addObjectsOnceFromArray:(NSArray *)otherArray;

@end