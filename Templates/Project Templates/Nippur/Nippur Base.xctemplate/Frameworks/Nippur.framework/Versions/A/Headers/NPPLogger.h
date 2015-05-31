/*
 *	NPPLog.h
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
#import "NPPCipher.h"

/*!
 *					Represents the log rule for #nppLog# function.
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

/*!
 *					Represents the log info for #nppLog# function.
 *
 *	@var			NPPLogInfoNone
 *					No extra info.
 *
 *	@var			NPPLogInfoThread
 *					The thread info will be appended.
 *
 *	@var			NPPLogInfoFunction
 *					The function/method info will be appended.
 *
 *	@var			NPPLogInfoClass
 *					The class info will be appended.
 *
 *	@var			NPPLogInfoFull
 *					All the infos above will be appended.
 */
typedef NS_OPTIONS(NSUInteger, NPPLogInfo)
{
	NPPLogInfoNone					= 0,
	NPPLogInfoThread				= 1 << 0,
	NPPLogInfoFunction				= 1 << 1,
	NPPLogInfoClass					= 1 << 2,
	NPPLogInfoFull					= NPPLogInfoThread | NPPLogInfoFunction | NPPLogInfoClass,
};

/*!
 *					This function checks if the log is currently available.
 *
 *	@result			A BOOL indicating if the log is available or not.
 */
NPP_API BOOL nppLogCheck(void);

/*!
 *					This function sets the log mode and info.
 *
 *					By default, the values are NPPLogModeDebugMacro and NPPLogInfoNone.
 *
 *	@param			mode
 *					The class info will be appended.
 *
 *	@param			info
 *					All the infos above will be appended.
 */
NPP_API void nppLogSetMode(NPPLogMode mode, NPPLogInfo info);

/*!
 *					The real log is made by this function. This function doesn't consider the log mode,
 *					this means you can call this function manually if you want to force a log anyway.
 *
 *	@param			function
 *					The function/methods' name that is generating the log.
 *
 *	@param			file
 *					The file name that is generating the log.
 *
 *	@param			format
 *					The log format string.
 *
 *	@param			...
 *					All the parameters/objects that are used by the format string.
 */
NPP_API void nppLogFull(const char *function, const char *file, NSString *format, ...);

/*!
 *					The log function. Call "nppLog" instead of "NSLog". It accept the very same inputs.
 *
 *	@param			format
 *					The log format string.
 *
 *	@param			...
 *					All the parameters/objects that are used by the format string.
 */
#define nppLog(format, ...) \
({ if (nppLogCheck()) { nppLogFull(__PRETTY_FUNCTION__, __FILE__, (format), ##__VA_ARGS__); } })

/*!
 *					The logger is a class intend for debug. It can save, load, write and read logs.
 *					Despite the instances of this class, the log file is only one and will be managed
 *					once per operation.
 *
 *					This class can also send and load the log from a server. This means you can remotely
 *					manage the logs from your application running on production.
 *
 *					It can also deal with the file's size. You can set a size limit to the log file,
 *					this means the older logs will be deleted when trying to save new logs.
 */
@interface NPPLogger : NSObject

/*!
 *					Appends a string to this instance.
 *
 *	@param			string
 *					A string with the log.
 */
- (void) appendString:(NSString *)string;

/*!
 *					Sets a string to this instance.
 *
 *	@param			string
 *					A string with the log.
 */
- (void) setString:(NSString *)string;

/*!
 *					Saves the string on this instance. That means, the string in this instance will be
 *					appended to the log file. After saving is done, the string on this instance is be reset.
 */
- (void) saveLogFile;

/*!
 *					Directly saves a string to the log file. That means, the string will be appended
 *					to the log file.
 *
 *	@param			string
 *					A string with the log.
 */
+ (void) saveLogString:(NSString *)string;

+ (void) logRemoteSend:(NSString *)user device:(NSString *)device completion:(NPPBlockVoid)block;
+ (void) logRemoteRequest:(NSString *)user device:(NSString *)device completion:(NPPBlockVoid)block;
+ (void) logRemoteDecode:(NSString *)remoteId completion:(NPPBlockArray)block;
+ (void) logLocalDecode:(NSString *)file completion:(NPPBlockArray)block;

+ (void) defineLogRemoteURL:(NSString *)url;
+ (void) defineLogRemoteBase:(NSString *)base;

/*!
 *					Defines the file's size limit to the log file.
 *
 *	@param			bytes
 *					The size limit in bytes.
 */
+ (void) defineLogSizeLimit:(double)bytes;

@end