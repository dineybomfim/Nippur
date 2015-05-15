/*
 *	NPPLog.h
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
typedef NS_OPTIONS(NSUInteger, NPPLogMode)
{
	NPPLogModeDebugMacro,			// Default - Only for Open Source version, otherwise it does not print.
	NPPLogModeBETA,
	NPPLogModeAlways,
};

typedef NS_OPTIONS(NSUInteger, NPPLogInfo)
{
	NPPLogInfoNone					= 0,
	NPPLogInfoThread				= 1 << 0,
	NPPLogInfoFunction				= 1 << 1,
	NPPLogInfoClass					= 1 << 2,
	NPPLogInfoFull					= NPPLogInfoThread | NPPLogInfoFunction | NPPLogInfoClass,
};

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