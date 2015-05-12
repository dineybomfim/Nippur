/*
 *	NPPDataManager.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 02/27/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPDataManager.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (AES256)

- (NSData *) AES256EncryptWithKey:(NSString *)key
{
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *) AES256DecryptWithKey:(NSString *)key
{
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
										  keyPtr, kCCKeySizeAES256,
										  NULL /* initialization vector (optional) */,
										  [self bytes], dataLength, /* input */
										  buffer, bufferSize, /* output */
										  &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
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
NPP_STATIC_READONLY(getCrossData, NSMutableDictionary);
NPP_STATIC_READONLY(getDataManager, NSMutableDictionary);

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
	NSString *local = (appFolder != nil) ? appFolder : nppGetApplicationName();
	
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
		case NPPDataFolderNippur:
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
#pragma mark Local Storage API
//*************************
//	Local Storage API
//*************************

+ (void) saveLocal:(id)data name:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder
{
	CFTimeInterval startTime = nppAbsoluteTime();
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
	
	nppLog(@"\"%@\" saved in:%f", name, (float)(nppAbsoluteTime() - startTime));
}

+ (id) loadLocal:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder
{
	CFTimeInterval startTime = nppAbsoluteTime();
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
	
	nppLog(@"\"%@\" loaded in:%f", name, (float)(nppAbsoluteTime() - startTime));
	
	return data;
}

+ (void) appendLocal:(id)data name:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder
{
	CFTimeInterval startTime = nppAbsoluteTime();
	
	NSString *localPath = [nppDataManagerPath(folder) stringByAppendingPathComponent:name];
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:localPath];
	[fileHandle seekToEndOfFile];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:localPath])
	{
		[self saveLocal:@"1.0" name:name type:type folder:folder];
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
	
	nppLog(@"\"%@\" appended in:%f", name, (float)(nppAbsoluteTime() - startTime));
}

+ (void) saveLocalArchive:(id)data name:(NSString *)name
{
	[self saveLocal:data name:name type:NPPDataTypeArchive folder:NPPDataFolderUser];
}

+ (id) loadLocalArchive:(NSString *)name
{
	return [self loadLocal:name type:NPPDataTypeArchive folder:NPPDataFolderUser];
}

+ (void) saveLocalString:(NSString *)string name:(NSString *)name
{
	[self saveLocal:string name:name type:NPPDataTypeString folder:NPPDataFolderUser];
}

+ (NSString *) loadLocalString:(NSString *)name
{
	return [self loadLocal:name type:NPPDataTypeString folder:NPPDataFolderUser];
}

+ (void) saveLocalPlist:(NSDictionary *)plist name:(NSString *)name
{
	[self saveLocal:plist name:name type:NPPDataTypePlist folder:NPPDataFolderUser];
}

+ (NSDictionary *) loadLocalPlist:(NSString *)name
{
	return [self loadLocal:name type:NPPDataTypePlist folder:NPPDataFolderUser];
}

#pragma mark -
#pragma mark File Oprations API
//*************************
//	File Oprations API
//*************************

+ (NSString *) pathForFolder:(NPPDataFolder)folder
{
	return nppDataManagerPath(folder);
}

+ (NSString *) pathForFile:(NSString *)named folder:(NPPDataFolder)folder
{
	return [NSString stringWithFormat:@"%@/%@", nppDataManagerPath(folder), named];
}

+ (void) copyFromPath:(NSString *)fromPath toPath:(NSString *)toPath overriding:(BOOL)override
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Checks if the new file exists.
	if ([fileManager fileExistsAtPath:fromPath])
	{
		// Removing the old file.
		if (override)
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

+ (void) copyFromBundleToLocal:(NSString *)named overriding:(BOOL)override
{
	[self copyFromPath:nppMakePath(named) toPath:nppDataManagerFilePath(named) overriding:override];
}

+ (void) moveFromLocalToUser:(NSString *)named
{
	NSString *localPath = [nppDataManagerPath(NPPDataFolderApp) stringByAppendingPathComponent:named];
	NSString *userPath = [nppDataManagerPath(NPPDataFolderUser) stringByAppendingPathComponent:named];
	
	[self moveFromPath:localPath toPath:userPath];
}

+ (BOOL) hasLocalNamed:(NSString *)named
{
	return [self hasLocalNamed:named folder:NPPDataFolderUser];
}

+ (BOOL) hasLocalNamed:(NSString *)named folder:(NPPDataFolder)folder
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *localPath = [nppDataManagerPath(folder) stringByAppendingPathComponent:named];
	
	return [fileManager fileExistsAtPath:localPath];
}

+ (void) deleteLocalNamed:(NSString *)named
{
	[self deleteLocalNamed:named folder:NPPDataFolderUser];
}

+ (void) deleteLocalNamed:(NSString *)named folder:(NPPDataFolder)folder
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
	
	[NPPDataManager saveLocal:info
						 name:NPPDataManagerFile
						 type:NPPDataTypeArchive
					   folder:NPPDataFolderNippur];
	
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
	
	[NPPDataManager saveLocal:info
						 name:NPPDataManagerFile
						 type:NPPDataTypeArchive
					   folder:NPPDataFolderNippur];
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
		[NPPDataManager saveLocal:info
							 name:NPPDataManagerFile
							 type:NPPDataTypeArchive
						   folder:NPPDataFolderNippur];
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
		NSDictionary *localInfo = [NPPDataManager loadLocal:NPPDataManagerFile
													   type:NPPDataTypeArchive
													 folder:NPPDataFolderNippur];
		
		[info setDictionary:localInfo];
	}
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end