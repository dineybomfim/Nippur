/*
 *	NPPConnector.h
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

#import "NPPRuntime.h"
#import "NPPFunctions.h"
#import "NPPString+NSString.h"
#import "NPPArray+NSArray.h"
#import "NPPDate+NSDate.h"
#import "NPPJSON.h"
#import "NPPDataManager.h"
#import "NPPLogger.h"

/*!
 *					Defines the connection method.
 *
 *	@var			NPPHTTPMethodGET
 *					HTTP GET.
 *
 *	@var			NPPHTTPMethodHEAD
 *					HTTP HEAD.
 *
 *	@var			NPPHTTPMethodPOST
 *					HTTP POST.
 *
 *	@var			NPPHTTPMethodPUT
 *					HTTP PUT.
 *
 *	@var			NPPHTTPMethodDELETE
 *					HTTP DELETE.
 *
 *	@var			NPPHTTPMethodTRACE
 *					HTTP TRACE.
 *
 *	@var			NPPHTTPMethodCONNECT
 *					HTTP CONNECT.
 */
typedef enum
{
	NPPHTTPMethodGET,
	NPPHTTPMethodHEAD,
	NPPHTTPMethodPOST,
	NPPHTTPMethodPUT,
	NPPHTTPMethodDELETE,
	NPPHTTPMethodTRACE,
	NPPHTTPMethodCONNECT,
} NPPHTTPMethod;

/*!
 *					Defines the connection state.
 *
 *	@var			NPPConnectorStateReady
 *					The connection is ready to start.
 *
 *	@var			NPPConnectorStateOpening
 *					The connection has started, but not receiving any package yet.
 *
 *	@var			NPPConnectorStateReceiving
 *					The connection has start receiving packages, the header is already loaded.
 *
 *	@var			NPPConnectorStateCompleted
 *					The connection has completed all its bytes.
 *
 *	@var			NPPConnectorStateFailed
 *					The connection has failed with an error.
 *
 *	@var			NPPConnectorStateCancelled
 *					The connection was cancelled manually.
 */
typedef enum
{
	NPPConnectorStateReady,
	NPPConnectorStateOpening,
	NPPConnectorStateReceiving,
	NPPConnectorStateCompleted,
	NPPConnectorStateFailed,
	NPPConnectorStateCancelled,
} NPPConnectorState;

/*!
 *					Notification about a connection starting (NPPConnectorStateOpening).
 */
NPP_API NSString *const NPPKeyConnectorDidStart;

/*!
 *					Notification about a connection receiving (NPPConnectorStateReceiving).
 */
NPP_API NSString *const NPPKeyConnectorDidResponse;

/*!
 *					Notification about a connection finishing (NPPConnectorStateCompleted).
 */
NPP_API NSString *const NPPKeyConnectorDidFinish;

/*!
 *					Notification about a connection failed (NPPConnectorState{Failed,Cancelled}).
 */
NPP_API NSString *const NPPConnectorErrorDomain;

@class NPPConnector;

/*!
 *					Defines the connector block.
 */
typedef void (^NPPBlockConnector)(NPP_ARC_UNSAFE NPPConnector *connector);

extern NSString *nppHTTPParamsToString(NSDictionary *params);
extern NSDictionary *nppHTTPStringToParams(NSString *string);
extern NSData *nppHTTPParamsToData(NSDictionary *params);
extern NSDictionary *nppHTTPDataToParams(NSData *data);

/*!
 *					The connector is a main thread free, asynchronously connection to any online service,
 *					endpoint or resource.
 *
 *					Each instance of this class is capable to deal with one connection. There is no limit
 *					on how many connections you can create with this class, the limitations are imposed
 *					by the platforms and the connection protocol.
 *
 *					This class is also able to deal with streaming connections and keep-alive type. In this
 *					case, the callbacks will assume a special behavior.
 *
 *					Also, it can handle with the log automatically. It generates full logs for debug
 *					purposes, local files for investigation and safe encriptions ciphers and algorithms to
 *					protect log data when used in "Release" state.
 */
@interface NPPConnector : NSObject <NSURLConnectionDataDelegate>
{
@private
	NSURLConnection				*_conn;
	NPPBlockConnector			_block;
	NSMutableString				*_log;
	
@protected
	NPPConnectorState			_state;
	int							_statusCode;
	long long					_contentLength;
	NSDictionary				*_receivedHeader;
	NSMutableData				*_receivedData;
	NSError						*_error;
	
	unsigned int				_currentRetry;
	unsigned int				_retries;
	BOOL						_logging;
}

// Returning data.
@property (nonatomic, readonly) NPPConnectorState state;
@property (nonatomic, readonly) int statusCode;
@property (nonatomic, readonly) long long contentLength;
@property (nonatomic, readonly) NSDictionary *receivedHeader;
@property (nonatomic, readonly) NSData *receivedData;
@property (nonatomic, readonly) NSError *error;

// Behaviors.
@property (nonatomic, readonly) unsigned int retries;
@property (nonatomic, readonly, getter = isLogging) BOOL logging;

// Starts immediately.
+ (id) connectorWithRequest:(NSURLRequest *)request completion:(NPPBlockConnector)block;
+ (id) connectorWithURL:(NSString *)url
				 method:(NPPHTTPMethod)method
				headers:(NSDictionary *)headers
				   body:(id)body
			 completion:(NPPBlockConnector)block;

// Cancels a connection with a desired URL and returns if it succeed in canceling or not. Accept RegEx.
+ (BOOL) cancelConnectorWithURL:(NSString *)urlPattern;
+ (BOOL) cancelConnector:(NPPConnector *)connector;

// Specific rules, that means rules matching the URL is strongest than a global rule (rule using "*").
+ (void) defineRetries:(unsigned int)retries forURL:(NSString *)urlPattern; // "*" = all, default 0
+ (void) defineLogging:(BOOL)isLogging forURL:(NSString *)urlPattern; // "*" = all, default YES
+ (void) defineTimeout:(double)timeout; // Default is 30.0. Minimum is 1.0

@end