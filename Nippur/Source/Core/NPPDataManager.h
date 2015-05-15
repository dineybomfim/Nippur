/*
 *	NPPDataManager.h
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
#import "NPPLogger.h"

/*!
 *					Represents the data type for a file.
 *
 *	@var			NPPDataTypeArchive
 *					Binary file format, it uses the secure dynamic Nippur cipher as it's encription.
 *
 *	@var			NPPDataTypeString
 *					Plain text file format.
 *
 *	@var			NPPDataTypePlist
 *					Key-Value in XML format.
 */
typedef NS_OPTIONS(NSUInteger, NPPDataType)
{
	NPPDataTypeArchive,
	NPPDataTypeString,
	NPPDataTypePlist,
};

/*!
 *					Represents a file system path inside the local sandbox.
 *
 *	@var			NPPDataFolderUser
 *					The defined user folder.
 *
 *	@var			NPPDataFolderApp
 *					The defined app folder.
 *
 *	@var			NPPDataFolderNippur
 *					Folder used by the framework.
 *
 *	@var			NPPDataFolderDocuments
 *					Documents folder, used by iTunes.
 *
 *	@var			NPPDataFolderLibrary
 *					The library folder.
 *
 *	@var			NPPDataFolderBundle
 *					The bundle folder, this folder is ready-only on iOS system.
 */
typedef NS_OPTIONS(NSUInteger, NPPDataFolder)
{
	NPPDataFolderUser,
	NPPDataFolderApp,
	NPPDataFolderNippur,
	NPPDataFolderDocuments,
	NPPDataFolderLibrary,
	NPPDataFolderBundle,
};

/*!
 *					The data manager is responsible for dealing with files, files' data, management on
 *					file system, saving and loading local files.
 */
@interface NPPDataManager : NSObject

//*************************
//	Transient Storage API
//*************************

/*!
 *					Retrieves an object previously set using the NPPDataManager's Transient Storage API.
 *
 *	@var			key
 *					The key previously set for an object.
 *
 *	@see			setObject:forKey:
 *	@see			removeObjectForKey:
 */
+ (id) objectForKey:(id)key;

/*!
 *					This method sets a object in the NPPDataManager's Transient Storage API.
 *					It uses the heap memory, that means you're the responsible for any object you set
 *					this way.
 *
 *	@var			object
 *					The object you want to put in the heap. This object will be retained internally.
 *
 *	@var			key
 *					The key for this object, it will be copied internally, so it must conforms to
 *					NSCopying protocol.
 *
 *	@see			objectForKey:
 *	@see			removeObjectForKey:
 */
+ (void) setObject:(id)object forKey:(id)key;

/*!
 *					Removes an object previously set using the NPPDataManager's Transient Storage API.
 *
 *	@var			key
 *					The key previously set for an object.
 *
 *	@see			objectForKey:
 *	@see			setObject:forKey:
 */
+ (void) removeObjectForKey:(id)key;

//*************************
//	Persistent Storage API
//*************************

/*!
 *					Loads a data from a file using the NPPDataManager's Persistent Storage API.
 *
 *	@var			name
 *					The file's name.
 *
 *	@var			type
 *					The file's type.
 *
 *	@var			folder
 *					The folder in which the file will be saved.
 *
 *	@result			The loaded file content. It can be nil if the file is invalid or not found.
 */
+ (id) loadFile:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder;

/*!
 *					Saves a data into a file using the NPPDataManager's Persistent Storage API.
 *
 *	@var			data
 *					The data to save. It must be an object conforming to NSCoding protocol.
 *
 *	@var			name
 *					The file's name.
 *
 *	@var			type
 *					The file's type.
 *
 *	@var			folder
 *					The folder in which the file will be saved.
 */
+ (void) saveFile:(id)data name:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder;

/*!
 *					Appends a data into a file using the NPPDataManager's Persistent Storage API.
 *					This method is intend to be used to append data into at the end of large files,
 *					it's faster because it doesn't loads the entire file into the memory, it just writes
 *					the new data at the end of the file.
 *
 *					This method will create a new file in case you try to append data to a file
 *					that doesn't exist yet.
 *
 *	@var			name
 *					The file's name.
 *
 *	@var			type
 *					The file's type.
 *
 *	@var			folder
 *					The folder in which the file will be saved.
 *
 *	@result			The loaded file content. It can be nil if the file is invalid or not found.
 */
+ (void) appendFile:(id)data name:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder;

// File Oprations API.
+ (NSString *) pathForFolder:(NPPDataFolder)folder;
+ (NSString *) pathForFile:(NSString *)named folder:(NPPDataFolder)folder;
+ (void) copyFromPath:(NSString *)fromPath toPath:(NSString *)toPath overriding:(BOOL)overriding;
+ (void) moveFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
+ (void) copyFromBundleToLocal:(NSString *)named overriding:(BOOL)overriding;
+ (void) moveFromAppFolderToUserFolder:(NSString *)named;
+ (BOOL) hasFileNamed:(NSString *)named folder:(NPPDataFolder)folder;
+ (void) deleteFileNamed:(NSString *)named folder:(NPPDataFolder)folder;
+ (void) deleteFolder:(NPPDataFolder)folder;
+ (void) deleteEverythingBeforeVersion:(NSString *)version build:(NSString *)build;
+ (NSDictionary *) attributesOfFile:(NSString *)named folder:(NPPDataFolder)folder;

// Global definitions. It's persistent and can keep the folder settings even across app opens.
+ (void) defineAppFolder:(NSString *)folderName;
+ (void) defineUserFolder:(NSString *)folderName;
+ (void) defineAppVersion:(NSString *)version build:(NSString *)build; // nil parameter means skip it.

@end