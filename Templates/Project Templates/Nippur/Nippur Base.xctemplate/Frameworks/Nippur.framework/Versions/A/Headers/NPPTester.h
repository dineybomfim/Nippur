/*
 *	NPPTester.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 2/23/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPFunctions.h"
#import "NPPLogger.h"

typedef enum
{
	NPPTesterUnitSeconds,			//Default
	NPPTesterUnitMilliseconds,
	NPPTesterUnitMicroseconds,
	NPPTesterUnitNanoseconds,
} NPPTesterUnit;

@interface NPPTester : NSObject
{
@private
	
}

+ (void) testerStress:(NSString *)name
				 unit:(NPPTesterUnit)unit
		   iterations:(unsigned int)loops
				block:(NPPBlockVoid)block;

@end