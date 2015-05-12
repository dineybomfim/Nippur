/*
 *	NPPTester.m
 *	Nippur
 *	
 *	Created by Diney Bomfim on 2/23/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPTester.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPTester

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

+ (void) testerStress:(NSString *)name
				 unit:(NPPTesterUnit)unit
		   iterations:(unsigned int)loops
				block:(NPPBlockVoid)block
{
	if (loops == 0)
	{
		nppLog(@"--- Testing can't run with 0 loops ---");
		return;
	}
	
	unsigned int i = 0;
	double currentTime = 0.0;
	double totalTime = 0.0;
	double fastest = NPP_MAX_32;
	double slowest = 0;
	unsigned int fastestIndex = 0;
	unsigned int slowestIndex = 0;
	NSMutableString *results = nil;
	NSString *kind = nil;
	double factor = 0.0f;
	
	switch (unit)
	{
		case NPPTesterUnitNanoseconds:
			kind = @"ns";
			factor = 1000000000.0;
			break;
		case NPPTesterUnitMicroseconds:
			kind = @"µs";
			factor = 1000000.0;
			break;
		case NPPTesterUnitMilliseconds:
			kind = @"ms";
			factor = 1000.0;
			break;
		case NPPTesterUnitSeconds:
		default:
			kind = @"s";
			factor = 1.0;
			break;
	}
	
	nppLog(@"--- Start Testing %@ ---", name);
	
	for (i = 0; i < loops; ++i)
	{
		currentTime = nppAbsoluteTime();
		
		// Runs the command.
		nppBlock(block);
		
		currentTime = nppAbsoluteTime() - currentTime;
		totalTime += currentTime;
		
		// Tracking the fastest loop.
		if (fastest > currentTime)
		{
			fastest = currentTime;
			fastestIndex = i;
		}
		
		// Tracking the slowest loop.
		if (slowest < currentTime)
		{
			slowest = currentTime;
			slowestIndex = i;
		}
	}
	
	results = [NSMutableString stringWithString:@"\n--- Results:\n"];
	[results appendFormat:@"\tElapsed time \t=\t %.7f %@\n", totalTime * factor, kind];
	[results appendFormat:@"\tAverage loop \t=\t %.7f %@\n", totalTime / loops * factor, kind];
	[results appendFormat:@"\tFastest index \t=\t [%i]\n", fastestIndex];
	[results appendFormat:@"\tFastest loop \t=\t %.7f %@\n", fastest * factor, kind];
	[results appendFormat:@"\tSlowest index \t=\t [%i]\n", slowestIndex];
	[results appendFormat:@"\tSlowest loop \t=\t %.7f %@\n", slowest * factor, kind];
	
	nppLog(@"\n%@\n", results);
	nppLog(@"--- Finish Testing %@ ---", name);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************


@end
