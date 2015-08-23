/*
 *	NPPConnector.h
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
#import "NPPPluginString.h"
#import "NPPPluginArray.h"
#import "NPPPluginDate.h"
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
typedef NS_OPTIONS(NSUInteger, NPPHTTPMethod)
{
	NPPHTTPMethodGET,
	NPPHTTPMethodHEAD,
	NPPHTTPMethodPOST,
	NPPHTTPMethodPUT,
	NPPHTTPMethodDELETE,
	NPPHTTPMethodTRACE,
	NPPHTTPMethodCONNECT,
};

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
typedef NS_OPTIONS(NSUInteger, NPPConnectorState)
{
	NPPConnectorStateReady,
	NPPConnectorStateOpening,
	NPPConnectorStateReceiving,
	NPPConnectorStateCompleted,
	NPPConnectorStateFailed,
	NPPConnectorStateCancelled,
};

/*!
 *					Notification about a connection starting (NPPConnectorStateOpening).
 */
NPP_API NSString *const kNPPKeyConnectorDidStart;

/*!
 *					Notification about a connection receiving (NPPConnectorStateReceiving).
 */
NPP_API NSString *const kNPPKeyConnectorDidResponse;

/*!
 *					Notification about a connection finishing (NPPConnectorStateCompleted).
 */
NPP_API NSString *const kNPPKeyConnectorDidFinish;

@class NPPConnector;

/*!
 *					Defines the connector block.
 */
typedef void (^nppBlockConnector)(NPP_ARC_UNSAFE NPPConnector *connector);

/*!
 *					The connector is an asynchronously connection to any online service, endpoint
 *					or resource using HTTP or FTP protocols. It's built using the URL Loading System:
 *					https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/URLLoadingSystem
 *
 *					Each instance of this class is capable to deal with one connection. There is no limit
 *					on how many connections you can create with this class, the limitations are imposed
 *					by the platforms and the connection protocol.
 *
 *					Also, it can handle with the log automatically. It generates full logs for debug
 *					purposes, local files for investigation and safe encriptions ciphers and algorithms to
 *					protect log data when used in "Release" state.
 */
@interface NPPConnector : NSObject <NSURLConnectionDataDelegate>
{
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

/*!
 *					The current state of this connector.
 */
@property (nonatomic, readonly) NPPConnectorState state;

/*!
 *					The returned HTTP status code. The default value is 0.
 */
@property (nonatomic, readonly) int statusCode;

/*!
 *					The returned HTTP content-length. The default value is 0.
 */
@property (nonatomic, readonly) long long contentLength;

/*!
 *					The returned HTTP header. The default value is nil.
 */
@property (nonatomic, readonly) NSDictionary *receivedHeader;

/*!
 *					The returned HTTP response. The default value is nil.
 */
@property (nonatomic, readonly) NSHTTPURLResponse *receivedResponse;

/*!
 *					The returned HTTP data. The default value is nil.
 */
@property (nonatomic, readonly) NSData *receivedData;

/*!
 *					The returned connection error. The default value is nil. A connection error is not
 *					the same as HTTP error. A HTTP with status code +400 or +500 is not treat as connection
 *					error. This error is all about the connection:
 *						- A lost of WiFi, 4G, 3G, Edge or celular data signal;
 *						- Connection timeout;
 *						- Connection interruption (not intentional);
 */
@property (nonatomic, readonly) NSError *error;

/*!
 *					The NSURLRequest for this connector.
 */
@property (nonatomic, readonly) NSURLRequest *request;

/*!
 *					The number of retries. A retry is just made when an connection error is returned.
 */
@property (nonatomic, readonly) unsigned int retries;

/*!
 *					The log will be shown in the console and saved in local file, all accordingly to
 *					the defined log rules.
 *
 *	@see			NPPLogger
 */
@property (nonatomic, readonly, getter = isLogging) BOOL logging;

/*!
 *					Starts a connection immediately based on the imput parameters.
 *
 *	@param			request
 *					A NSURLRequest defined before.
 *
 *	@param			block
 *					The finish block. It'll be called when the connection ends (successfully or not).
 */
+ (id) connectorWithRequest:(NSURLRequest *)request completion:(nppBlockConnector)block;

/*!
 *					Starts a connection immediately based on the imput parameters.
 *
 *	@param			url
 *					The url string. You can or not include GET parameters in this string. This class
 *					will wisely handle the #body# to correctly concatenate with this string, if necessary.
 *
 *	@param			method
 *					The HTTP method.
 *
 *	@param			headers
 *					A custom dictionary for connection header.
 *
 *	@param			body
 *					A parameters or body of this request.
 *
 *	@param			block
 *					The finish block. It'll be called when the connection ends (successfully or not).
 */
+ (id) connectorWithURL:(NSString *)url
				 method:(NPPHTTPMethod)method
				headers:(NSDictionary *)headers
				   body:(id)body
			 completion:(nppBlockConnector)block;

/*!
 *					Cancels one or more connections with the matching URL pattern and returns a BOOL
 *					indicating if the cancellation had success or not. This pattern is a RegEx.
 *
 *	@param			urlPattern
 *					A pattern using RegEx format. For example, you could use "*" to match all connections
 *					or "google" to match any connection with "google" in the url.
 */
+ (BOOL) cancelConnectorWithURL:(NSString *)urlPattern;

/*!
 *					Cancels one specific connection and returns a BOOL indicating
 *					if the cancellation had success or not.
 *
 *	@param			connector
 *					The connector instance to be canceled.
 */
+ (BOOL) cancelConnector:(NPPConnector *)connector;

/*!
 *					Defines the number of retries to any new connection with the matching URL pattern.
 *					A specific rule will override a global rule (global rule = "*").
 *					By default, connections have 0 retries defined.
 *
 *	@param			retries
 *					The number of retries to define.
 *
 *	@param			urlPattern
 *					A pattern using RegEx format. For example, you could use "*" to match all connections
 *					or "google" to match any connection with "google" in the url.
 */
+ (void) defineRetries:(unsigned int)retries forURL:(NSString *)urlPattern;

/*!
 *					Defines the log ability to any new connection with the matching URL pattern.
 *					A specific rule will override a global rule (global rule = "*").
 *					By default, connections have logging set to YES.
 *
 *	@var			isLogging
 *					A BOOL indicating if it should log or not.
 *
 *	@var			urlPattern
 *					A pattern using RegEx format. For example, you could use "*" to match all connections
 *					or "google" to match any connection with "google" in the url.
 */
+ (void) defineLogging:(BOOL)isLogging forURL:(NSString *)urlPattern;

@end