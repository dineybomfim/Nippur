/*
 *	NPPConnector.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 02/27/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPFunctions.h"
#import "NPPString+NSString.h"
#import "NPPArray+NSArray.h"
#import "NPPDate+NSDate.h"
#import "NPPJSON.h"
#import "NPPDataManager.h"
#import "NPPLogger.h"

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

typedef enum
{
	NPPConnectorStateReady,
	NPPConnectorStateOpening,
	NPPConnectorStateReceiving,
	NPPConnectorStateCompleted,
	NPPConnectorStateFailed,
	NPPConnectorStateCancelled,
} NPPConnectorState;

NPP_API NSString *const NPPKeyConnectorDidStart;
NPP_API NSString *const NPPKeyConnectorDidResponse;
NPP_API NSString *const NPPKeyConnectorDidFinish;
NPP_API NSString *const NPPConnectorErrorDomain;

@class NPPConnector;

typedef void (^NPPBlockConnector)(NPP_ARC_UNSAFE NPPConnector *connector);

extern NSString *nppHTTPParamsToString(NSDictionary *params);
extern NSDictionary *nppHTTPStringToParams(NSString *string);
extern NSData *nppHTTPParamsToData(NSDictionary *params);
extern NSDictionary *nppHTTPDataToParams(NSData *data);

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