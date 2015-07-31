/*
 *	NippurCoreTests.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NippurCore.h"

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

NPP_STATIC_READONLY(NSMutableDictionary, nppTestStatic);

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

@interface NippurCoreTests : XCTestCase

@end

@implementation NippurCoreTests

- (void) testBlockMacros_With4Blocks_ShouldSucceed
{
	XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	__block int count = 0;
	
	NPPBlockDictionary block = ^(NSDictionary *info)
	{
		nppLog(@"%@", info);
		
		if (++count >= 4)
		{
			[expectation fulfill];
		}
	};
	
	// Blocks
	nppBlock(block, @{@"test":@"nppBlock"});
	nppBlockMain(block, @{@"test":@"nppBlockMain"});
	nppBlockBG(block, @{@"test":@"nppBlockBG"});
	nppBlockAfter(2.0, block, @{@"test":@"nppBlockAfter"});
	
	// Static functions
	NSMutableDictionary *dict = nppTestStatic();
	XCTAssertNotNil(dict, @"NPP_STATIC_READONLY");
	
	[self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void) testConnector_WithHTTPMethods_ShouldSucceed
{
	XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	__block int count = 0;
	
	nppBlockConnector block = ^(NPPConnector *__unsafe_unretained connector)
	{
		NSString *link = connector.request.URL.absoluteString;
		nppLog(@"%@ - Received Bytes:%lli", link, connector.receivedData.length);
		
		if (++count >= 7)
		{
			[expectation fulfill];
		}
	};
	
	NSString *url = nil;
	NSString *const kNPPHTTPBin	= @"https://httpbin.org";
	
	url = [kNPPHTTPBin stringByAppendingString:@"/get"];
	[NPPConnector connectorWithURL:url method:NPPHTTPMethodGET headers:nil body:nil completion:block];
	
	url = [kNPPHTTPBin stringByAppendingString:@"/post"];
	[NPPConnector connectorWithURL:url method:NPPHTTPMethodPOST headers:nil body:nil completion:block];
	
	url = [kNPPHTTPBin stringByAppendingString:@"/put"];
	[NPPConnector connectorWithURL:url method:NPPHTTPMethodPUT headers:nil body:nil completion:block];
	
	url = [kNPPHTTPBin stringByAppendingString:@"/gzip"];
	[NPPConnector connectorWithURL:url method:NPPHTTPMethodGET headers:nil body:nil completion:block];
	
	url = [kNPPHTTPBin stringByAppendingString:@"/stream/100"];
	[NPPConnector connectorWithURL:url method:NPPHTTPMethodGET headers:nil body:nil completion:block];
	
	url = [kNPPHTTPBin stringByAppendingString:@"/image/png"];
	[NPPConnector connectorWithURL:url method:NPPHTTPMethodGET headers:nil body:nil completion:block];
	
	[NPPConnector defineRetries:2 forURL:@"*"];
	[NPPConnector defineLogging:NO forURL:@"*"];
	
	[self waitForExpectationsWithTimeout:15.0 handler:nil];
}

- (void) testConnector_WithCancellation_ShouldSucceed
{
	NSString *url = nil;
	NSString *const kNPPHTTPBin	= @"https://httpbin.org";
	
	NPPConnector *cancelConn = nil;
	url = [kNPPHTTPBin stringByAppendingString:@"/delay/15"];
	cancelConn = [NPPConnector connectorWithURL:url
										 method:NPPHTTPMethodGET
										headers:nil
										   body:nil
									 completion:nil];
	
	[NPPConnector cancelConnector:cancelConn];
	
	XCTAssert(cancelConn.state == NPPConnectorStateCancelled, "This connection was not cancelled");
}

- (void) testJSON_WithStringObjectAndData_ShouldSucceed
{
	NSString *jsonString = @"{ \"paramA\":\"value A\", \"paramB\":45, \"paramC\":true }";
	id object = nil;
	NSData *data = nil;
	
	object = [NPPJSON objectWithString:jsonString];
	XCTAssertNotNil(object, @"NPPJSON objectWithString");
	
	data = [NPPJSON dataWithObject:object];
	XCTAssertNotNil(data, @"NPPJSON dataWithObject");
	
	object = [NPPJSON objectWithData:data];
	XCTAssertNotNil(data, @"NPPJSON objectWithData");
	
	nppLog(@"%@", object);
}

- (void) testDataManager_WithStringAsArchive_ShouldSucceed
{
	NSString *jsonString = @"A string to save";
	[NPPDataManager saveFile:jsonString name:@"Test" type:NPPDataTypeArchive folder:NPPDataFolderApp];
	
	NSString *string = [NPPDataManager loadFile:@"Test" type:NPPDataTypeArchive folder:NPPDataFolderApp];
	
	XCTAssertNotNil(string, @"NPPDataManager loadFile");
	XCTAssertEqualObjects(string, jsonString, @"The loaded content is not the same as the original");
}

- (void) testClock_WithStartStopAndReset_ShouldSucceed
{
	NPPClockManager *clock = [[NPPClockManager alloc] initWithTotalTime:1.0];
	
	[clock start];
	[clock stop];
	[clock reset];
	
	XCTAssert(clock.currentTime == 0.0, "The current time should be now 0 (zero)");
}

- (void) testTester_WithStressTest_shouldOutputTheResults
{
	NPPBlockVoid block = ^(void)
	{
		int a = 2;
		int b = 3;
		int c = sqrt(pow(a, 2) + pow(b, 2));
		
		c = 0;
	};
	
	[NPPTester testerStress:@"Stress A" unit:NPPTesterUnitMilliseconds iterations:1000 block:block];
}

@end
