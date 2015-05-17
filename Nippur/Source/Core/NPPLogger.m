/*
 *	NPPLog.m
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

#import "NPPLogger.h"
#import "NPPFunctions.h"

#import "NPPConnector.h"
#import "NPPString+NSString.h"
#import "NPPJSON.h"
#import "NPPDataManager.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

NSString *const kNPPLogURL				= @"";
NSString *const kNPPLogData				= @"data/";
NSString *const kNPPLogSend				= @"send/";
NSString *const kNPPLogRequest			= @"request/";

#define kNPPREGEX_END_SLASH				@"\\/$"
#define NPP_FILE_LOG					@"NPPLog"

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

static double			_defaultMaxSize			= 50000000; // 50 Mb
static NPPLogMode		_defaultLogMode			= NPPLogModeDebugMacro;
static NPPLogInfo		_defaultLogInfo			= NPPLogInfoNone;
static int				_defaultLogCheck		= -1;
static NSString			*_defaultURL			= nil;
static NSString			*_defaultBase			= nil;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static NSMutableArray *nppGetLogFromString(NSString *logString)
{
	NSMutableArray *resultingLog = [NSMutableArray array];
	NSArray *array = [[logString decodeHTMLFull] componentsSeparatedByString:@"{##"];
	NSString *item = nil;
	unsigned long long i = 0;
	
	for (item in array)
	{
		if (i > 0)
		{
			item = [item stringByReplacingOccurrencesOfString:@"##}" withString:@""];
			item = [item decodeDoubleColumnar];
			
			[resultingLog addObject:[NSString stringWithFormat:@"%llu) %@", i, item]];
		}
		
		++i;
	}
	
	return resultingLog;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPLogger()
{
@private
	NSMutableString					*_string;
}

// Initializes a new instance.
- (void) initializing;

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

BOOL nppLogCheck(void)
{
	// Look at the bundle identifier once, since it can't change during the fly anyway.
	if (_defaultLogCheck == -1)
	{
		switch (_defaultLogMode)
		{
			case NPPLogModeBETA:
				_defaultLogCheck = nppBetaCheck();
				break;
			case NPPLogModeAlways:
				_defaultLogCheck = YES;
				break;
			case NPPLogModeDebugMacro:
			default:
#if NPP_DEBUG
				_defaultLogCheck = YES;
#endif
				break;
		}
	}
	
	return _defaultLogCheck;
}

void nppLogSetMode(NPPLogMode mode, NPPLogInfo info)
{
	_defaultLogMode = mode;
	_defaultLogInfo = info;
	
	// Reset the check variable, so it'll check again at next nppBetaCheck call.
	_defaultLogCheck = -1;
}

void nppLogFull(const char *function, const char *file, NSString *format, ...)
{
	NSMutableString *log = nil;
	NSThread *thread = nil;
	unsigned int threadIndex = 0;
	NSString *fileName = nil;
	log = [NSMutableString string];
	
	if ((_defaultLogInfo & NPPLogInfoThread))
	{
		thread = [NSThread currentThread];
		threadIndex = [[thread valueForKeyPath:@"private.seqNum"] intValue];
		[log appendFormat:@"Thread %i%@", threadIndex, ([thread isMainThread]) ? @" (Main)" : @""];
		[log appendString:@" :: "];
	}
	
	if ((_defaultLogInfo & NPPLogInfoFunction))
	{
		[log appendFormat:@"%s", function];
		[log appendString:@" :: "];
	}
	
	if ((_defaultLogInfo & NPPLogInfoClass))
	{
		fileName = [NSString stringWithUTF8String:file];
		[log appendFormat:@"%@", nppGetFileName(fileName)];
		[log appendString:@" :: "];
	}
	
	[log appendFormat:@"%@", format];
	
	va_list args;
	va_start(args, format);
	NSLogv(log, args);
	va_end(args);
}

@implementation NPPLogger

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

- (id) init
{
	if ((self = [super init]))
	{
		[self initializing];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	_string = [[NSMutableString alloc] init];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) appendString:(NSString *)string
{
	[_string appendString:string];
}

- (void) setString:(NSString *)string
{
	[_string setString:string];
}

- (void) saveLogFile
{
	// Dealing with log size limit.
	NSDictionary *attributes = [NPPDataManager attributesOfFile:NPP_FILE_LOG folder:NPPDataFolderNippur];
	
	if ([[attributes objectForKey:NSFileSize] doubleValue] >= _defaultMaxSize)
	{
		[NPPDataManager deleteFileNamed:NPP_FILE_LOG folder:NPPDataFolderNippur];
	}
	
	// Encrypting the string.
	NSString *log = [NSString stringWithFormat:@"{##%@##}", [_string encodeDoubleColumnar]];
	
	// Saves the encrypted log string.
	[NPPDataManager appendFile:log name:NPP_FILE_LOG type:NPPDataTypeString folder:NPPDataFolderNippur];
	
	// Resets the string for safety.
	[_string setString:@""];
}

+ (void) saveLogString:(NSString *)string
{
	NPPLogger *logFile = [[self alloc] init];
	
	[logFile setString:string];
	[logFile saveLogFile];
	
	nppRelease(logFile);
}

+ (void) logRemoteSend:(NSString *)user device:(NSString *)device completion:(NPPBlockVoid)block
{
	// {"logs":{"users":[],"devices":[]}}
	// "*" is valid and means ALL the users and devices.
	
	NPPBlockConnector callBack = ^(NPPConnector *connector)
	{
		id json = [NPPJSON objectWithData:connector.receivedData];
		BOOL sendLog = NO;
		NSString *match = nil;
		
		if ([json isKindOfClass:[NSDictionary class]])
		{
			NSDictionary *logs = [json objectForKey:@"logs"];
			NSArray *array = nil;
			NSString *item = nil;
			
			array = [logs objectForKey:@"users"];
			
			for (item in array)
			{
				if ([item isEqualToString:user] || [item isEqualToString:@"*"])
				{
					sendLog = YES;
					match = user;
					break;
				}
			}
			
			array = [logs objectForKey:@"devices"];
			
			for (item in array)
			{
				if ([item isEqualToString:device] || [item isEqualToString:@"*"])
				{
					sendLog = YES;
					match = device;
					break;
				}
			}
		}
		
		if (sendLog)
		{
			NSString *localLog = [NPPDataManager loadFile:NPP_FILE_LOG
													  type:NPPDataTypeString
													folder:NPPDataFolderNippur];
			
			NSString *url = [NSString stringWithFormat:@"%@%@", _defaultURL, kNPPLogSend];
			NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:
								  _defaultBase, @"base",
								  match, @"match",
								  [localLog encodeHTMLFull], @"log",
								  nil];
			
			NPPBlockConnector sentBlock = ^(NPPConnector *connector)
			{
				if (connector.statusCode == 200)
				{
					[NPPDataManager deleteFileNamed:NPP_FILE_LOG folder:NPPDataFolderNippur];
				}
				
				nppBlock(block);
			};
			
			[NPPConnector connectorWithURL:url
									method:NPPHTTPMethodPOST
								   headers:nil
									  body:body
								completion:sentBlock];
		}
	};
	
	NSString *url = [NSString stringWithFormat:@"%@%@%@", _defaultURL, kNPPLogData, _defaultBase];
	[NPPConnector connectorWithURL:url method:NPPHTTPMethodGET headers:nil body:nil completion:callBack];
}

+ (void) logRemoteRequest:(NSString *)user device:(NSString *)device completion:(NPPBlockVoid)block
{
	// {"logs":{"users":[],"devices":[]}}
	// "*" is valid and means ALL the users and devices.
	
	NSString *url = [NSString stringWithFormat:@"%@%@", _defaultURL, kNPPLogRequest];
	NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:
						  _defaultBase, @"base",
						  user, @"user",
						  device, @"device",
						  nil];
	
	NPPBlockConnector sentBlock = ^(NPPConnector *connector)
	{
		//id receivedData = [NPPJSON objectWithData:connector.receivedData];
		//[[receivedData objectForKey:@"status"] intValue] == 200
		
		if (connector.statusCode == 200)
		{
			// Success
		}
		
		nppBlock(block);
	};
	
	[NPPConnector connectorWithURL:url
							method:NPPHTTPMethodPOST
						   headers:nil
							  body:body
						completion:sentBlock];
}

+ (void) logRemoteDecode:(NSString *)remoteId completion:(NPPBlockArray)block
{
	NPPBlockConnector callBlock = ^(NPPConnector *connector)
	{
		NSString *log = [NSString stringWithData:connector.receivedData encoding:NSUTF8StringEncoding];
		nppBlock(block, nppGetLogFromString(log));
	};
	
	NSString *url = [NSString stringWithFormat:@"%@%@%@", _defaultURL, kNPPLogData, remoteId];
	[NPPConnector connectorWithURL:url method:NPPHTTPMethodPOST headers:nil body:nil completion:callBlock];
}

+ (void) logLocalDecode:(NSString *)file completion:(NPPBlockArray)block
{
	NSData *data = [NSData dataWithContentsOfFile:nppMakePath(file)];
	NSString *log = [NSString stringWithData:data encoding:NSUTF8StringEncoding];
	
	nppBlock(block, nppGetLogFromString(log));
}

+ (void) defineLogRemoteURL:(NSString *)url
{
	// Takes the default URL if an invalid url is set.
	url = (url == nil) ? kNPPLogURL : url;
	url = nppRegExReplace(url, kNPPREGEX_END_SLASH, @"/", NPPRegExFlagGDMI);
	
	nppRelease(_defaultURL);
	_defaultURL = [url copy];
	
	// Removes the logger url from being logged.
	[NPPConnector defineLogging:NO forURL:_defaultURL];
}

+ (void) defineLogRemoteBase:(NSString *)base
{
	nppRelease(_defaultBase);
	_defaultBase = [[base lowercaseString] copy];
}

+ (void) defineLogSizeLimit:(double)bytes
{
	_defaultMaxSize = bytes;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nppRelease(_string);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (void) initialize
{
	if (self == [NPPLogger class])
	{
		// Sets the default URL
		[self defineLogRemoteURL:nil];
	}
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
