/*
 *	NippurCoreTests.m
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Expecta.h"

#import "NippurCore.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

NSString *const kNPPHTTPBin	= @"https://httpbin.org";

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

- (void) testConnector
{
	XCTestExpectation *expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
	__block int count = 0;
	
	NPPBlockConnector block = ^(NPPConnector *__unsafe_unretained connector)
	{
		NSString *link = connector.request.URL.absoluteString;
		nppLog(@"%@ - Received Bytes:%lli", link, connector.receivedData.length);
		
		if (++count >= 6)
		{
			[expectation fulfill];
		}
	};
	
	NSString *url = nil;
	
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
	
	[self waitForExpectationsWithTimeout:15.0 handler:nil];
}

@end
