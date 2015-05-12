/*
 *	NPPLog.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 12/18/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPFunctions.h"
#import "NPPCipher.h"

/*!
 *					Defines the debug mode for #nppLog# function.
 *
 *	@var			NPPLogModeDebugMacro
 *					Only prints on console when running under DEBUG macro. By default, Xcode use this
 *					macro for any compilation excepet for "Profile" and "Archive" mode.
 *
 *	@var			NPPLogModeBETA
 *					Special Nippur pattern, only prints when there is a "beta" bundle identifier.
 *
 *	@var			NPPLogModeAlways
 *					Prints on the console everywhere.
 */
typedef enum
{
	NPPLogModeDebugMacro,			// Default - Only for Open Source version, otherwise it does not print.
	NPPLogModeBETA,
	NPPLogModeAlways,
} NPPLogMode;

typedef enum
{
	NPPLogInfoNone					= 0,
	NPPLogInfoThread				= 1 << 0,
	NPPLogInfoFunction				= 1 << 1,
	NPPLogInfoClass					= 1 << 2,
	NPPLogInfoFull					= NPPLogInfoThread | NPPLogInfoFunction | NPPLogInfoClass,
} NPPLogInfo;

typedef void (^NPPBlockLogs)(NPP_ARC_UNSAFE NSArray *logs);

// The default value is NPPLogModeDebugMacro and NPPLogInfoNone
NPP_API BOOL nppLogCheck(void);
NPP_API void nppLogSetMode(NPPLogMode mode, NPPLogInfo info);
NPP_API void nppLogFull(const char *function, const char *file, NSString *format, ...);

#define nppLog(format, ...) \
({ if (nppLogCheck()) { nppLogFull(__PRETTY_FUNCTION__, __FILE__, (format), ##__VA_ARGS__); } })

@interface NPPLogger : NSObject
{
@private
	
}

// Log string manipulation.
- (void) appendString:(NSString *)aString;
- (void) setString:(NSString *)aString;

// Saves the local log, appending it to the file. When it's saved, for security, the string is reset.
- (void) saveLogFile;
+ (void) saveLogString:(NSString *)aString;

+ (void) logRemoteSend:(NSString *)user device:(NSString *)device completion:(NPPBlockVoid)block;
+ (void) logRemoteRequest:(NSString *)user device:(NSString *)device completion:(NPPBlockVoid)block;
+ (void) logRemoteDecode:(NSString *)remoteId completion:(NPPBlockLogs)block;

+ (void) logLocalDecode:(NSString *)file completion:(NPPBlockLogs)block;

+ (void) defineLogRemoteURL:(NSString *)url;
+ (void) defineLogRemoteBase:(NSString *)base;
+ (void) defineLogSizeLimit:(double)bytes;

@end