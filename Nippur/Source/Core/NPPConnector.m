/*
 *	NPPConnector.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 02/27/12.
 *	Copyright 2012 db-in. All rights reserved.
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

NSString *const kNPPHTTPMethodGET			= @"GET";
NSString *const kNPPHTTPMethodHEAD			= @"HEAD";
NSString *const kNPPHTTPMethodPOST			= @"POST";
NSString *const kNPPHTTPMethodPUT			= @"PUT";
NSString *const kNPPHTTPMethodDELETE		= @"DELETE";
NSString *const kNPPHTTPMethodTRACE			= @"TRACE";
NSString *const kNPPHTTPMethodCONNECT		= @"CONNECT";

NSString *const NPPKeyConnectorDidStart		= @"NPPKeyConnectorDidStart";
NSString *const NPPKeyConnectorDidResponse	= @"NPPKeyConnectorDidResponse";
NSString *const NPPKeyConnectorDidFinish	= @"NPPKeyConnectorDidFinish";
NSString *const NPPConnectorErrorDomain		= @"NPPConnectorErrorDomain";

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

static double _defaultTimeout = 30.0;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

NPP_STATIC_READONLY(nppConnectorRetries, NSMutableDictionary);
NPP_STATIC_READONLY(nppConnectorLogs, NSMutableDictionary);
NPP_STATIC_READONLY(nppGetConnectors, NSMutableArray);

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

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPConnector()

@property (nonatomic, readonly) NSURLRequest *request;

// Initializes a new instance.
- (void) initializing;

- (id) initWithRequest:(NSURLRequest *)request completion:(NPPBlockConnector)block;
- (id) initWithURL:(NSString *)url
			method:(NPPHTTPMethod)method
		   headers:(NSDictionary *)headers
			  body:(id)body
		completion:(NPPBlockConnector)block;


- (void) startConnection;
- (void) closeConnection;
- (void) cancelConnection;

@end

#pragma mark -
#pragma mark Public Functions
#pragma mark -
//**********************************************************************************************************
//
//	Public Functions
//
//**********************************************************************************************************

NSString *nppHTTPParamsToString(NSDictionary *params)
{
	NSMutableString *string = [[NSMutableString alloc] init];
	
	// Dictionary params will be converted into string.
	if ([params isKindOfClass:[NSDictionary class]])
	{
		NSString *key = nil;
		NSString *param = nil;
		NSUInteger i = 0;
		NSUInteger count = [params count];
		
		// Constructs the parameters.
		for (key in params)
		{
			// Fully encode the HTML data.
			param = [NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]];
			[string appendFormat:@"%@%@", [param encodeHTMLFull], (++i < count) ? @"&" : @""];
		}
	}
	
	return nppAutorelease(string);
}

NSDictionary *nppHTTPStringToParams(NSString *string)
{
	NSMutableString *raw = nil;
	NSRange range = NPPRangeZero;
	
	// Slicing HTTP domain.
	if ([string hasPrefix:@"http"])
	{
		range = [string rangeOfString:@"?"];
		string = (range.length > 0) ? [string substringFromIndex:range.location + 1] : string;
	}
	
	raw = [NSMutableString stringWithString:string];
	
	// Preparing raw string.
	do
	{
		range = [raw rangeOfString:@"="];
		if (range.length > 0)
		{
			[raw replaceCharactersInRange:range withString:@"#::#"];
		}
		
		range = [raw rangeOfString:@"&"];
		if (range.length > 0)
		{
			[raw replaceCharactersInRange:range withString:@"#::#"];
		}
	}
	while (range.length > 0);
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	NSArray *array = [raw componentsSeparatedByString:@"#::#"];
	NSString *key = nil;
	NSString *value = nil;
	NSUInteger i = 0;
	NSUInteger count = [array count];
	
	for (i = 0; i < count; i += 2)
	{
		if (i + 1 < count)
		{
			key = [[array objectAtIndex:i] decodeHTMLFull];
			value = [[array objectAtIndex:i + 1] decodeHTMLFull];
		}
		else
		{
			key = [NSString stringWithFormat:@"param%i", (int)i];
			value = [[array objectAtIndex:i] decodeHTMLFull];
		}
		
		[params setObject:value forKey:key];
	}
	
	return nppAutorelease(params);
}

NSData *nppHTTPParamsToData(NSDictionary *params)
{
	NSString *string = nppHTTPParamsToString(params);
	
	return [string dataUsingEncoding:NSUTF8StringEncoding];
}

NSDictionary *nppHTTPDataToParams(NSData *data)
{
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *params = nppHTTPStringToParams(string);
	nppRelease(string);
	
	return params;
}

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPConnector

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize request = _request;
@synthesize state = _state, statusCode = _statusCode, contentLength = _contentLength,
			receivedHeader = _receivedHeader, receivedData = _receivedData, error = _error,
			retries = _retries, logging = _logging;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) initWithRequest:(NSURLRequest *)request completion:(NPPBlockConnector)block
{
	if ((self = [self init]))
	{
		_state = NPPConnectorStateReady;
		_block = [block copy];
		_request = [request copy];
		
		[self initializing];
	}
	
	return self;
}

- (id) initWithURL:(NSString *)url
			method:(NPPHTTPMethod)method
		   headers:(NSDictionary *)headers
			  body:(id)body
		completion:(NPPBlockConnector)block
{
	if ((self = [self init]))
	{
		_state = NPPConnectorStateReady;
		_block = [block copy];
		
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
		[request setTimeoutInterval:_defaultTimeout];
		
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
					httpData = nppHTTPParamsToString(body);
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
				httpData = nppHTTPParamsToString(body);
				
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
		
		_request = [request copy];
		nppRelease(request);
		
		[self initializing];
	}
	
	return self;
}

+ (id) connectorWithRequest:(NSURLRequest *)request completion:(NPPBlockConnector)block
{
	NPPConnector *conn = [[self alloc] initWithRequest:request completion:block];
	[conn startConnection];
	
	return nppAutorelease(conn);
}

+ (id) connectorWithURL:(NSString *)url
				 method:(NPPHTTPMethod)method
				headers:(NSDictionary *)headers
				   body:(id)body
			 completion:(NPPBlockConnector)block
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
	NSArray *keys = nil;
	NSString *key = nil;
	NSRange range;
	
	_retries = 0;
	_logging = YES;
	
	// Retries.
	keys = [retriesDict allKeys];
	
	for (key in keys)
	{
		range = [url rangeOfString:key];
		
		// Searching for any rule.
		if (range.length > 0 || [key isEqualToString:@"*"])
		{
			_retries = [[retriesDict objectForKey:key] unsignedIntValue];
			
			// A specific rule is strongest than a global rule.
			if (range.length > 0)
			{
				break;
			}
		}
	}
	
	// Logging.
	keys = [logsDict allKeys];
	
	for (key in keys)
	{
		range = [url rangeOfString:key];
		
		// Searching for any rule.
		if (range.length > 0 || [key isEqualToString:@"*"])
		{
			_logging = [[logsDict objectForKey:key] unsignedIntValue];
			
			// A specific rule is strongest than a global rule.
			if (range.length > 0)
			{
				break;
			}
		}
	}
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
	
	// Creates the connection.
	nppRelease(_conn);
	nppRelease(_receivedData);
	_receivedData = [[NSMutableData alloc] init];
	_conn = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:YES];
	
	if (_conn == nil)
	{
		[self closeConnection];
	}
	
	// Just send notification for the first attempt and when it's logging.
	if (_currentRetry == 0 && _logging)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:NPPKeyConnectorDidStart object:self];
		//nppBlockMain();
	}
	
	//*************************
	//	Log
	//*************************
	
	if (_logging)
	{
		NSString *method = [_request HTTPMethod];
		
		// Starting the log.
		nppRelease(_log);
		_log = [[NSMutableString alloc] init];
		[_log appendFormat:@"%@", [[NSDate date] stringWithFormat:@"yyyy-MM-dd HH:mm:ss:SSS"]];
		[_log appendFormat:@" REQUEST: %@ %@", method, [[_request URL] absoluteString]];
		[_log appendFormat:@" HEADER: %@", [NPPJSON stringWithObject:[_request allHTTPHeaderFields]]];
		
		if ([method isEqualToString:kNPPHTTPMethodPOST] || [method isEqualToString:kNPPHTTPMethodPUT])
		{
			//TODO: Set Log limit
			NSDictionary *params = nppHTTPDataToParams([_request HTTPBody]);
			[_log appendFormat:@" BODY: %@", [NPPJSON stringWithObject:params]];
		}
		
		// Log in console.
		nppLog(@"%@", [_log stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""]);
	}
}

- (void) closeConnection
{
	// Callback block.
	nppBlock(_block, self);
	
	// Closing the connection.
	[_conn cancel];
	
	// Cleaning up the connectors.
	NSMutableArray *connectors = nppGetConnectors();
	[connectors removeObjectIdenticalTo:self];
	
	// Just send notification when it's logging.
	if (_logging)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:NPPKeyConnectorDidFinish object:self];
		//nppBlockMain();
	}
	
	// Resets the number of retries.
	_currentRetry = 0;
	
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
}

- (void) cancelConnection
{
	nppRelease(_error);
	_error = [[NSError alloc] initWithDomain:NPPConnectorErrorDomain code:ECANCELED userInfo:nil];
	_statusCode = 0;
	_state = NPPConnectorStateCancelled;
	
	[self closeConnection];
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
	_state = NPPConnectorStateReceiving;
	
	// Just send notification when it's logging.
	if (_logging)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:NPPKeyConnectorDidResponse object:self];
		//nppBlockMain();
	}
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_receivedData appendData:data];
	
	//TODO another subclass.
	/*
	 if (_isStreaming)
	 {
	 nppBlock(_block, self);
	 [_receivedData setData:nil];
	 }
	 //*/
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
	NSMutableDictionary *retriesDict = nppConnectorRetries();
	
	[retriesDict setObject:[NSNumber numberWithUnsignedInt:retries] forKey:urlPattern];
}

+ (void) defineLogging:(BOOL)isLogging forURL:(NSString *)urlPattern
{
	NSMutableDictionary *retriesDict = nppConnectorLogs();
	
	[retriesDict setObject:[NSNumber numberWithBool:isLogging] forKey:urlPattern];
}

+ (void) defineTimeout:(double)timeout
{
	_defaultTimeout = MAX(timeout, 1.0);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nppRelease(_conn);
	nppRelease(_block);
	nppRelease(_log);
	nppRelease(_receivedHeader);
	nppRelease(_receivedData);
	nppRelease(_error);
	nppRelease(_request);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end