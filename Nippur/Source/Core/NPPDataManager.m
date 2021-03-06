/*
 *	NPPDataManager.m
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

#import "NPPDataManager.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (AES256)

- (NSData *) AES256EncryptWithKey:(NSString *)key
{
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256 + 1];
	bzero(keyPtr, sizeof(keyPtr));
	
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES256,
										  NULL,
										  [self bytes], dataLength,
										  buffer, bufferSize,
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	
	free(buffer);
	return nil;
}

- (NSData *) AES256DecryptWithKey:(NSString *)key
{
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256 + 1];
	bzero(keyPtr, sizeof(keyPtr));
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES256,
										  NULL,
										  [self bytes], dataLength,
										  buffer, bufferSize,
										  &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer);
	return nil;
}

@end

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPPModelCipherKey			@"dXi3Afi2p3djdgHN0MnaIreOwa35agkDagD3ebT5MjaAkY47BsDfhN10DtMncZlo"
#define NPPDataManagerFile			@"NPPDataManager"
#define NPPKeyAppFolder				@"NPPKeyAppFolder"
#define NPPKeyUserFolder			@"NPPKeyUserFolder"
#define NPPKeyAppVersion			@"NPPKeyAppVersion"
#define NPPKeyAppBuild				@"NPPKeyAppBuild"

#define kNPPREGEX_FILE_NAME			@"(\\/|:|\\?|\\&|\\=|%)"

//		kCCAlgorithmAES = 0,		Advanced Encryption Standard, 128-bit block
//		kCCAlgorithmDES,			Data Encryption Standard
//		kCCAlgorithm3DES,			Triple-DES, three key, EDE configuration
//		kCCAlgorithmCAST,			CAST
//		kCCAlgorithmRC4,			RC4 stream cipher
//		kCCAlgorithmBlowfish		Blowfish block cipher

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

// Full path to the local folder.
static NSString *_localPath = nil;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

// Global dictionary.
NPP_STATIC_READONLY(NSMutableDictionary, getCrossData);
NPP_STATIC_READONLY(NSMutableDictionary, getDataManager);

// Global path to the local folder.
static NSString *nppDataManagerPath(NPPDataFolder folder)
{
	NSSearchPathDirectory directory = NSLibraryDirectory;
	NSSearchPathDomainMask domainMask = NSUserDomainMask;
	NSMutableDictionary *info = getDataManager();
	NSString *appFolder = [info objectForKey:NPPKeyAppFolder];
	NSString *userFolder = [info objectForKey:NPPKeyUserFolder];
	
	// Special search in documents directory.
	if (folder == NPPDataFolderDocuments)
	{
		directory = NSDocumentDirectory;
	}
	
	// Create the full path to the App's folder.
	NSArray *fileSystem = NSSearchPathForDirectoriesInDomains(directory, domainMask, YES);
	NSString *path = ([fileSystem count] > 0) ? [fileSystem objectAtIndex:0] : nil;
	NSString *local = (appFolder != nil) ? appFolder : nppGetBundleName();
	
	// Appends the user folder to the local path.
	if (folder == NPPDataFolderUser && userFolder != nil)
	{
		local = [local stringByAppendingPathComponent:userFolder];
	}
	
	switch (folder)
	{
		case NPPDataFolderLibrary:
		case NPPDataFolderDocuments:
			// Just use the path as it is.
			break;
		case NPPDataFolderFramework:
			path = [path stringByAppendingPathComponent:NPP_NAME];
			break;
		case NPPDataFolderBundle:
			path = [[NSBundle mainBundle] bundlePath];
			break;
		case NPPDataFolderUser:
		case NPPDataFolderApp:
		default:
			path = [path stringByAppendingPathComponent:local];
			break;
	}
	
	// Create the folder with default configurations.
	// This method automatically skips if the folder already exist.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:path])
	{
		[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	return path;
}

// Global path to the local folder.
static NSString *nppDataManagerFilePath(NSString *fileName)
{
	if (_localPath == nil)
	{
		NSString *localPath = nppDataManagerPath(NPPDataFolderUser);
		
		// Create the full path to the App's folder.
		_localPath = [localPath copy];
	};
	
	fileName = nppRegExReplace(fileName, kNPPREGEX_FILE_NAME, @"", NPPRegExFlagGDMI);
	NSString *fullPath = [NSString stringWithFormat:@"%@/%@", _localPath, fileName];
	
	return fullPath;
}

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPDataManager

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

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark Cross Data API
//*************************
//	Cross Data API
//*************************

+ (id) objectForKey:(id)key
{
	return [getCrossData() objectForKey:key];
}

+ (void) setObject:(id)object forKey:(id)key
{
	// Just inserts not nil objects.
	if (object != nil)
	{
		[getCrossData() setObject:object forKey:key];
	}
	// Setting an object to nil is the same as remove it.
	else
	{
		[getCrossData() removeObjectForKey:key];
	}
}

+ (void) removeObjectForKey:(id)key
{
	[getCrossData() removeObjectForKey:key];
}

#pragma mark -
#pragma mark Persistent Storage API
//*************************
//	Persistent Storage API
//*************************

+ (id) loadFile:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder
{
	NSString *localPath = [nppDataManagerPath(folder) stringByAppendingPathComponent:name];
	id data = nil;
	
	// Unarchiving data.
	if (type == NPPDataTypeArchive)
	{
		NSData *store = [[NSData dataWithContentsOfFile:localPath] AES256DecryptWithKey:NPPModelCipherKey];
		
		if (store != nil)
		{
			NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:store];
			data = [unarchiver decodeObjectForKey:name];
			[unarchiver finishDecoding];
			nppRelease(unarchiver);
		}
	}
	else if (type == NPPDataTypeString)
	{
		data = [NSString stringWithContentsOfFile:localPath encoding:NSUTF8StringEncoding error:nil];
	}
	else if (type == NPPDataTypePlist)
	{
		data = [NSDictionary dictionaryWithContentsOfFile:localPath];
	}
	
	return data;
}

+ (void) saveFile:(id)data name:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder
{
	NSString *localPath = [nppDataManagerPath(folder) stringByAppendingPathComponent:name];
	
	// Archiving data.
	if (type == NPPDataTypeArchive)
	{
		NSMutableData *store = [NSMutableData data];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:store];
		[archiver encodeObject:data forKey:name];
		[archiver finishEncoding];
		nppRelease(archiver);
		
		[[store AES256EncryptWithKey:NPPModelCipherKey] writeToFile:localPath atomically:YES];
	}
	else if (type == NPPDataTypeString)
	{
		[data writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
	else if (type == NPPDataTypePlist)
	{
		[data writeToFile:localPath atomically:YES];
	}
}

+ (void) appendFile:(id)data name:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder
{
	NSString *localPath = [nppDataManagerPath(folder) stringByAppendingPathComponent:name];
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:localPath];
	[fileHandle seekToEndOfFile];
	
	// Creating a new file if needed.
	if (![[NSFileManager defaultManager] fileExistsAtPath:localPath])
	{
		[self saveFile:@"" name:name type:type folder:folder];
	}
	
	// Archiving data.
	if (type == NPPDataTypeArchive)
	{
		[fileHandle writeData:data];
	}
	else if (type == NPPDataTypeString)
	{
		[fileHandle writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
	}
	else if (type == NPPDataTypePlist)
	{
		NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:localPath];
		[plist addEntriesFromDictionary:data];
		[plist writeToFile:localPath atomically:YES];
		nppRelease(plist);
	}
	
	[fileHandle closeFile];
}

+ (NSString *) pathForFolder:(NPPDataFolder)folder
{
	return nppDataManagerPath(folder);
}

+ (NSString *) pathForFile:(NSString *)named folder:(NPPDataFolder)folder
{
	return [NSString stringWithFormat:@"%@/%@", nppDataManagerPath(folder), named];
}

+ (void) copyFromPath:(NSString *)fromPath toPath:(NSString *)toPath overriding:(BOOL)overriding
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Checks if the new file exists.
	if ([fileManager fileExistsAtPath:fromPath])
	{
		// Removing the old file.
		if (overriding)
		{
			[fileManager removeItemAtPath:toPath error:nil];
		}
		
		// Copying the new one.
		if (![fileManager fileExistsAtPath:toPath])
		{
			[fileManager copyItemAtPath:fromPath toPath:toPath error:nil];
		}
	}
}

+ (void) moveFromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// This operation will override the file in the destination path.
	[fileManager moveItemAtPath:fromPath toPath:toPath error:nil];
}

+ (void) copyFromBundleToLocal:(NSString *)named overriding:(BOOL)overriding
{
	[self copyFromPath:nppMakePath(named) toPath:nppDataManagerFilePath(named) overriding:overriding];
}

+ (void) moveFromAppFolderToUserFolder:(NSString *)named
{
	NSString *localPath = [nppDataManagerPath(NPPDataFolderApp) stringByAppendingPathComponent:named];
	NSString *userPath = [nppDataManagerPath(NPPDataFolderUser) stringByAppendingPathComponent:named];
	
	[self moveFromPath:localPath toPath:userPath];
}

+ (BOOL) hasFileNamed:(NSString *)named folder:(NPPDataFolder)folder
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *localPath = [nppDataManagerPath(folder) stringByAppendingPathComponent:named];
	
	return [fileManager fileExistsAtPath:localPath];
}

+ (void) deleteFileNamed:(NSString *)named folder:(NPPDataFolder)folder
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *localPath = [nppDataManagerPath(folder) stringByAppendingPathComponent:named];
	
	// Checks if the new file exists.
	if ([fileManager fileExistsAtPath:localPath])
	{
		[fileManager removeItemAtPath:localPath error:nil];
	}
}

+ (void) deleteFolder:(NPPDataFolder)folder
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *localPath = nppDataManagerPath(folder);
	
	[fileManager removeItemAtPath:localPath error:nil];
}

+ (void) deleteEverythingBeforeVersion:(NSString *)version build:(NSString *)build
{
	NSMutableDictionary *info = getDataManager();
	BOOL canDelete = NO;
	
	if (version != nil && [[info objectForKey:NPPKeyAppVersion] floatValue] < [version floatValue])
	{
		canDelete = YES;
	}
	
	if (build != nil && [[info objectForKey:NPPKeyAppBuild] floatValue] < [build floatValue])
	{
		canDelete = YES;
	}
	
	if (canDelete)
	{
		[self deleteFolder:NPPDataFolderDocuments];
		[self deleteFolder:NPPDataFolderLibrary];
	}
}

+ (NSDictionary *) attributesOfFile:(NSString *)named folder:(NPPDataFolder)folder
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *localPath = [nppDataManagerPath(folder) stringByAppendingPathComponent:named];
	NSDictionary *attributes = [fileManager attributesOfItemAtPath:localPath error:nil];
	
	return attributes;
}

#pragma mark -
#pragma mark Global definitions
//*************************
//	Global definitions
//*************************

+ (void) defineAppFolder:(NSString *)folderName
{
	if (folderName == nil)
	{
		return;
	}
	
	// Clears the current reference for local path.
	nppRelease(_localPath);
	
	NSMutableDictionary *info = getDataManager();
	
	[info setObject:folderName forKey:NPPKeyAppFolder];
	
	[NPPDataManager saveFile:info
						 name:NPPDataManagerFile
						 type:NPPDataTypeArchive
					   folder:NPPDataFolderFramework];
	
}

+ (void) defineUserFolder:(NSString *)folderName
{
	// Clears the current reference for local path.
	nppRelease(_localPath);
	
	NSMutableDictionary *info = getDataManager();
	
	if (folderName != nil)
	{
		[info setObject:folderName forKey:NPPKeyUserFolder];
	}
	else
	{
		[info removeObjectForKey:NPPKeyUserFolder];
	}
	
	[NPPDataManager saveFile:info
						 name:NPPDataManagerFile
						 type:NPPDataTypeArchive
					   folder:NPPDataFolderFramework];
}

+ (void) defineAppVersion:(NSString *)version build:(NSString *)build
{
	NSMutableDictionary *info = getDataManager();
	BOOL hasChange = NO;
	
	// Skips nil paramters and make sure it is really changing.
	if (version != nil && ![version isEqualToString:[info objectForKey:NPPKeyAppVersion]])
	{
		[info setObject:version forKey:NPPKeyAppVersion];
		hasChange = YES;
	}
	
	// Skips nil paramters and make sure it is really changing.
	if (build != nil && ![build isEqualToString:[info objectForKey:NPPKeyAppBuild]])
	{
		[info setObject:build forKey:NPPKeyAppBuild];
		hasChange = YES;
	}
	
	// Just save real changes.
	if (hasChange)
	{
		[NPPDataManager saveFile:info
							 name:NPPDataManagerFile
							 type:NPPDataTypeArchive
						   folder:NPPDataFolderFramework];
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

+ (void) initialize
{
	if (self == [NPPDataManager class])
	{
		// Loading the persistent Data Manager configurations.
		NSMutableDictionary *info = getDataManager();
		NSDictionary *localInfo = [NPPDataManager loadFile:NPPDataManagerFile
													   type:NPPDataTypeArchive
													 folder:NPPDataFolderFramework];
		
		[info setDictionary:localInfo];
	}
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end