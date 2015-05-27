/*
 *	NPPTester.h
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
#import "NPPLogger.h"

/*!
 *					Represents a unit of measure.
 *
 *	@var			NPPTesterUnitSeconds
 *					It represents the time in seconds.
 *
 *	@var			NPPTesterUnitMilliseconds
 *					It represents the time in milli seconds (seconds/1000).
 *
 *	@var			NPPTesterUnitMicroseconds
 *					It represents the time in micro seconds (seconds/1000000).
 *
 *	@var			NPPTesterUnitNanoseconds
 *					It represents the time in nano seconds (seconds/1000000000).
 */
typedef NS_OPTIONS(NSUInteger, NPPTesterUnit)
{
	NPPTesterUnitSeconds,			//Default
	NPPTesterUnitMilliseconds,
	NPPTesterUnitMicroseconds,
	NPPTesterUnitNanoseconds,
};

/*!
 *					This class was made to make tests. It can have and support any kind of TDD, including
 *					performance tests, stress tests, etc.
 *
 *					IMPORTANT: This class has no safe locks to avoid you publishing tests on your
 *					production enviroment, so try to use it only on your tests build, not inside your
 *					app code.
 */
@interface NPPTester : NSObject

/*!
 *					Runs a stress test on a block. You can define how many iterations the block will
 *					have, that means, how many times it'll be executed over and over. This methods
 *					outputs its results on the console.
 *
 *					The results include the total time, the average time of iterations, the fastest one and
 *					the slowest one.
 *
 *	@param			name
 *					The name for this test.
 *
 *	@param			unit
 *					The unit measure to show on the output.
 *
 *	@param			loops
 *					The number of iterations that this test will run (usually 1000-1000000 is enough).
 *
 *	@param			block
 *					The testing block it self.
 */
+ (void) testerStress:(NSString *)name
				 unit:(NPPTesterUnit)unit
		   iterations:(unsigned int)loops
				block:(NPPBlockVoid)block;

@end