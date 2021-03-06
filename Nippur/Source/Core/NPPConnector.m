/*
 *	NPPConnector.m
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

#import "NPPConnector.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_CONN_TIMEOUT			20.0

NSString *const kNPPHTTPMethodGET			= @"GET";
NSString *const kNPPHTTPMethodHEAD			= @"HEAD";
NSString *const kNPPHTTPMethodPOST			= @"POST";
NSString *const kNPPHTTPMethodPUT			= @"PUT";
NSString *const kNPPHTTPMethodDELETE		= @"DELETE";
NSString *const kNPPHTTPMethodTRACE			= @"TRACE";
NSString *const kNPPHTTPMethodCONNECT		= @"CONNECT";

NSString *const kNPPKeyConnectorDidStart	= @"kNPPKeyConnectorDidStart";
NSString *const kNPPKeyConnectorDidResponse	= @"kNPPKeyConnectorDidResponse";
NSString *const kNPPKeyConnectorDidFinish	= @"kNPPKeyConnectorDidFinish";
NSString *const kNPPConnectorErrorDomain	= @"kNPPConnectorErrorDomain";

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

//static double _defaultTimeout = 30.0;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

NPP_STATIC_READONLY(NSMutableDictionary, nppConnectorRetries);
NPP_STATIC_READONLY(NSMutableDictionary, nppConnectorLogs);
NPP_STATIC_READONLY(NSMutableArray, nppGetConnectors);

static NSString *nppValidateHTTPMethod(NPPHTTPMethod method)
{
	NSString *finalMethod = kNPPHTTPMethodGET;
	
	switch (method)
	{
		case NPPHTTPMethodHEAD:
			finalMethod = kNPPHTTPMethodHEAD;
			break;
		case NPPHTTPMethodPOST:
			finalMethod = kNPPHTTPMethodPOST;
			break;
		case NPPHTTPMethodPUT:
			finalMethod = kNPPHTTPMethodPUT;
			break;
		case NPPHTTPMethodDELETE:
			finalMethod = kNPPHTTPMethodDELETE;
			break;
		case NPPHTTPMethodTRACE:
			finalMethod = kNPPHTTPMethodTRACE;
			break;
		case NPPHTTPMethodCONNECT:
			finalMethod = kNPPHTTPMethodCONNECT;
			break;
		default:
			break;
	}
	
	return finalMethod;
}

static id nppConnectorReadPattern(NSDictionary *dict, NSString *url)
{
	id object = nil;
	NSArray *keys = nil;
	NSString *key = nil;
	NSRange range;
	
	// Retries.
	keys = [dict allKeys];
	
	for (key in keys)
	{
		range = [url rangeOfString:key];
		
		// Searching for any rule.
		if (range.length > 0 || [key isEqualToString:@"*"])
		{
			object = [dict objectForKey:key];
			
			// A specific rule is strongest than a global rule.
			if (range.length > 0)
			{
				break;
			}
		}
	}
	
	return object;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPConnector()
{
@private
	NSURLConnection				*_conn;
	NSURLRequest				*_request;
	nppBlockConnector			_block;
	NSMutableString				*_log;
}

@property (nonatomic, NPP_RETAIN) NSURLRequest *request;
@property (nonatomic, NPP_COPY) nppBlockConnector block;

// Initializes a new instance.
- (void) initializing;

- (id) initWithRequest:(NSURLRequest *)request completion:(nppBlockConnector)block;
- (id) initWithURL:(NSString *)url
			method:(NPPHTTPMethod)method
		   headers:(NSDictionary *)headers
			  body:(id)body
		completion:(nppBlockConnector)block;


- (void) startConnection;
- (void) closeConnection;
- (void) cancelConnection;

- (void) parseResponse:(NSURLResponse *)response;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Public Functions
//**************************************************
//	Public Functions
//**************************************************

#pragma mark -
#pragma mark Public Class
//**************************************************
//	Public Class
//**************************************************

@implementation NPPConnector

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize request = _request, block = _block;
@synthesize state = _state, statusCode = _statusCode, contentLength = _contentLength,
			receivedHeader = _receivedHeader, receivedResponse = _receivedResponse,
			receivedData = _receivedData, error = _error, retries = _retries, logging = _logging;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) initWithRequest:(NSURLRequest *)request completion:(nppBlockConnector)block
{
	if ((self = [self init]))
	{
		_state = NPPConnectorStateReady;
		self.block = block;
		self.request = request;
		
		[self initializing];
	}
	
	return self;
}

- (id) initWithURL:(NSString *)url
			method:(NPPHTTPMethod)method
		   headers:(NSDictionary *)headers
			  body:(id)body
		completion:(nppBlockConnector)block
{
	if ((self = [self init]))
	{
		//*************************
		//	Request
		//*************************
		
		NSString *fullURL = [url encodeHTMLURL];
		NSMutableURLRequest *request = nil;
		NSString *field = nil;
		NSString *contentLength = nil;
		NSArray *components = nil;
		NSString *urlString = nil;
		NSURL *url = nil;
		NSData *bodyData = nil;
		NSString *httpData = nil;
		
		// Basic and most used HTTP standard.
		request = [[NSMutableURLRequest alloc] init];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
		[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
		[request setTimeoutInterval:NPP_CONN_TIMEOUT];
		
		// Creating POST and GET requests.
		switch (method)
		{
				// Requests with post body.
			case NPPHTTPMethodPOST:
			case NPPHTTPMethodPUT:
				// NSData bodies will be passed directly.
				if ([body isKindOfClass:[NSData class]])
				{
					bodyData = body;
				}
				else
				{
					httpData = [NSString stringWithHTTPParams:body];
					bodyData = [httpData dataUsingEncoding:NSUTF8StringEncoding];
				}
				
				contentLength = [NSString stringWithFormat:@"%u", (unsigned int)[bodyData length]];
				[request setValue:contentLength forHTTPHeaderField:@"content-length"];
				[request setHTTPBody:bodyData];
				url = [NSURL URLWithString:fullURL];
				break;
				// Requests without post body.
			default:
				components = [fullURL componentsSeparatedByString:@"?"];
				urlString = [components firstObject];
				httpData = [NSString stringWithHTTPParams:body];
				
				// Appends any previous GET data.
				if ([components count] > 1)
				{
					httpData = ([httpData length] > 0) ? [httpData stringByAppendingString:@"&"] : @"";
					httpData = [httpData stringByAppendingString:[components objectAtIndex:1]];
				}
				
				// Checks if there is a data to go.
				if ([httpData length] > 0)
				{
					// Appends the GET data.
					urlString = [urlString stringByAppendingFormat:@"?%@", httpData];
				}
				
				url = [NSURL URLWithString:urlString];
				break;
		}
		
		[request setHTTPMethod:nppValidateHTTPMethod(method)];
		[request setURL:url];
		
		//*************************
		//	Headers
		//*************************
		
		// Adding custom header fields.
		for (field in headers)
		{
			[request setValue:[headers objectForKey:field] forHTTPHeaderField:field];
		}
		
		_state = NPPConnectorStateReady;
		self.block = block;
		self.request = request;
		
		nppRelease(request);
		
		[self initializing];
	}
	
	return self;
}

+ (id) connectorWithRequest:(NSURLRequest *)request completion:(nppBlockConnector)block
{
	NPPConnector *conn = [[self alloc] initWithRequest:request completion:block];
	[conn startConnection];
	
	return nppAutorelease(conn);
}

+ (id) connectorWithURL:(NSString *)url
				 method:(NPPHTTPMethod)method
				headers:(NSDictionary *)headers
				   body:(id)body
			 completion:(nppBlockConnector)block
{
	NPPConnector *conn = nil;
	conn = [[self alloc] initWithURL:url method:method headers:headers body:body completion:block];
	[conn startConnection];
	
	return nppAutorelease(conn);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	NSString *url = [[_request URL] absoluteString];
	NSMutableDictionary *retriesDict = nppConnectorRetries();
	NSMutableDictionary *logsDict = nppConnectorLogs();
	id object = nil;
	
	object = nppConnectorReadPattern(retriesDict, url);
	_retries = [object unsignedIntValue];
	
	object = nppConnectorReadPattern(logsDict, url);
	_logging = (object != nil) ? [object boolValue] : YES;
}

- (void) startConnection
{
	// The connection is always forced to run on the main thread and it's always an Asynchronous request.
	if (![[NSThread currentThread] isMainThread])
	{
		[self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:NO];
		return;
	}
	
	_state = NPPConnectorStateOpening;
	
	NSMutableArray *connectors = nppGetConnectors();
	[connectors addObjectOnce:self];
	
	//*************************
	//	Connector
	//*************************
	//*
	// Creates the connection.
	nppRelease(_conn);
	nppRelease(_receivedData);
	_receivedData = [[NSMutableData alloc] init];
	_conn = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:NO];
	[_conn scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_conn start];
	
	if (_conn == nil)
	{
		[self closeConnection];
	}
	/*/
	void (^block)(NSData *, NSURLResponse *, NSError *) = ^(NSData *d, NSURLResponse *r, NSError *e)
	{
		[self parseResponse:r];
		
		nppRelease(_receivedData);
		_receivedData = [d copy];
		
		nppRelease(_error);
		_error = [e copy];
		
		if (_error == nil)
		{
			_state = NPPConnectorStateCompleted;
			[self closeConnection];
		}
		else
		{
			if (_currentRetry < _retries)
			{
				++_currentRetry;
				[self startConnection];
			}
			else
			{
				_state = NPPConnectorStateFailed;
				[self closeConnection];
			}
		}
	};
	NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:_request completionHandler:block];
	[task resume];
	//*/
	
	//*************************
	//	Log
	//*************************
	
	if (_logging)
	{
		NSString *method = [_request HTTPMethod];
		NSDictionary *headers = [_request allHTTPHeaderFields];
		
		// Starting the log.
		nppRelease(_log);
		_log = [[NSMutableString alloc] init];
		[_log appendFormat:@"%@", [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss:SSS"]];
		[_log appendFormat:@" REQUEST: %@ %@", method, [[_request URL] absoluteString]];
		
		if (headers != nil)
		{
			[_log appendFormat:@" HEADER: %@", [NPPJSON stringWithObject:headers]];
		}
		
		if ([method isEqualToString:kNPPHTTPMethodPOST] || [method isEqualToString:kNPPHTTPMethodPUT])
		{
			//TODO: Set Log limit
			NSDictionary *params = [[_request HTTPBody] httpParams];
			[_log appendFormat:@" BODY: %@", [NPPJSON stringWithObject:params]];
		}
		
		// Log in console.
		nppLog(@"%@", [_log stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]);
	}
	
	//*************************
	//	Notification
	//*************************
	
	// Just send notification for the first attempt and when it's logging.
	//if (_currentRetry == 0 && _logging)
	if (_currentRetry == 0)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kNPPKeyConnectorDidStart object:self];
	}
}

- (void) closeConnection
{
	//*************************
	//	Notification
	//*************************
	
	// Just send notification when it's logging.
	//if (_logging)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kNPPKeyConnectorDidFinish object:self];
	}
	
	//*************************
	//	Log
	//*************************
	
	if (_logging && _state != NPPConnectorStateCancelled)
	{
		// Finishing the log.
		NSString *body = [NSString stringWithData:_receivedData encoding:NSUTF8StringEncoding];
		[_log appendFormat:@"\n%@", [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss:SSS"]];
		[_log appendFormat:@" RESPONSE: %i %lli", _statusCode, _contentLength];
		[_log appendFormat:@" CONTENT: %@", (_error != nil) ? _error : body];
		
		// Saving the log.
		[NPPLogger saveLogString:_log];
	}
	
	nppRelease(_log);
	
	//*************************
	//	Closing
	//*************************
	
	// Callback block.
	nppBlock(_block, self);
	nppRelease(_block);
	
	// Closing the connection.
	[_conn cancel];
	
	// Cleaning up the connectors.
	NSMutableArray *connectors = nppGetConnectors();
	[connectors removeObjectIdenticalTo:self];
	
	// Resets the number of retries.
	_currentRetry = 0;
}

- (void) cancelConnection
{
	nppRelease(_error);
	_error = [[NSError alloc] initWithDomain:kNPPConnectorErrorDomain code:ECANCELED userInfo:nil];
	_statusCode = 0;
	_state = NPPConnectorStateCancelled;
	
	[self closeConnection];
}

- (void) parseResponse:(NSURLResponse *)response
{
	if ([response respondsToSelector:@selector(statusCode)])
	{
		_statusCode = (int)[(NSHTTPURLResponse *)response statusCode];
	}
	
	if ([response respondsToSelector:@selector(allHeaderFields)])
	{
		nppRelease(_receivedHeader);
		_receivedHeader = nppRetain([(NSHTTPURLResponse *)response allHeaderFields]);
	}
	
	_contentLength = [response expectedContentLength];
	
	nppRelease(_receivedResponse);
	_receivedResponse = (NSHTTPURLResponse *)nppRetain(response);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark NSURLConnectionDataDelegate
//*************************
//	NSURLConnectionDataDelegate
//*************************

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	_state = NPPConnectorStateReceiving;
	[self parseResponse:response];
	
	//*************************
	//	Notification
	//*************************
	
	// Just send notification when it's logging.
	//if (_logging)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:kNPPKeyConnectorDidResponse object:self];
	}
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_receivedData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	_state = NPPConnectorStateCompleted;
	[self closeConnection];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	nppRelease(_error);
	_error = [error copy];
	
	if (_currentRetry < _retries)
	{
		++_currentRetry;
		[self startConnection];
	}
	else
	{
		_state = NPPConnectorStateFailed;
		[self closeConnection];
	}
}

#pragma mark -
#pragma mark Self
//*************************
//	Self
//*************************

+ (BOOL) cancelConnectorWithURL:(NSString *)urlPattern
{
	NSArray *connectors = [NSArray arrayWithArray:nppGetConnectors()];
	NPPConnector *conn = nil;
	NSString *connURL = nil;
	BOOL hasFound = NO;
	
	// Searching for a connector that matches the URL.
	for (conn in connectors)
	{
		connURL = [[[conn request] URL] absoluteString];
		
		if (nppRegExMatch(connURL, urlPattern, NPPRegExFlagGDMI) &&
			conn.state != NPPConnectorStateCompleted)
		{
			hasFound = YES;
			[conn cancelConnection];
		}
	}
	
	return hasFound;
}

+ (BOOL) cancelConnector:(NPPConnector *)connector
{
	NSArray *connectors = [NSArray arrayWithArray:nppGetConnectors()];
	NPPConnector *conn = nil;
	BOOL hasFound = NO;
	
	// Searching for a connector that matches the URL.
	for (conn in connectors)
	{
		if (conn == connector &&
			conn.state != NPPConnectorStateCompleted)
		{
			hasFound = YES;
			[conn cancelConnection];
			break;
		}
	}
	
	return hasFound;
}

+ (void) defineRetries:(unsigned int)retries forURL:(NSString *)urlPattern
{
	NSMutableDictionary *dict = nppConnectorRetries();
	
	[dict setObject:[NSNumber numberWithUnsignedInt:retries] forKey:urlPattern];
}

+ (void) defineLogging:(BOOL)isLogging forURL:(NSString *)urlPattern
{
	NSMutableDictionary *dict = nppConnectorLogs();
	
	[dict setObject:[NSNumber numberWithBool:isLogging] forKey:urlPattern];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nppRelease(_conn);
	nppRelease(_request);
	nppRelease(_block);
	nppRelease(_log);
	
	nppRelease(_receivedHeader);
	nppRelease(_receivedResponse);
	nppRelease(_receivedData);
	nppRelease(_error);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end