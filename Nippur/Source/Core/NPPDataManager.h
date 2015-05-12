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

typedef enum
{
	NPPDataTypeArchive,
	NPPDataTypeString,
	NPPDataTypePlist,
} NPPDataType;

typedef enum
{
	NPPDataFolderUser,
	NPPDataFolderApp,
	NPPDataFolderNippur,
	NPPDataFolderDocuments,
	NPPDataFolderLibrary,
	NPPDataFolderBundle,		// Read-only
} NPPDataFolder;

@interface NPPDataManager : NSObject

// Cross Data API.
+ (id) objectForKey:(id)key;
+ (void) setObject:(id)object forKey:(id)key;
+ (void) removeObjectForKey:(id)key;

// Local Storage API.
+ (void) saveLocal:(id)data name:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder;
+ (id) loadLocal:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder;
+ (void) appendLocal:(id)data name:(NSString *)name type:(NPPDataType)type folder:(NPPDataFolder)folder;

// Local Storage API - User folder | App folder shortcut.
+ (void) saveLocalArchive:(id)data name:(NSString *)name;
+ (id) loadLocalArchive:(NSString *)name;
+ (void) saveLocalString:(NSString *)string name:(NSString *)name;
+ (NSString *) loadLocalString:(NSString *)name;
+ (void) saveLocalPlist:(NSDictionary *)string name:(NSString *)name;
+ (NSDictionary *) loadLocalPlist:(NSString *)name;

// File Oprations API.
+ (NSString *) pathForFolder:(NPPDataFolder)folder;
+ (NSString *) pathForFile:(NSString *)named folder:(NPPDataFolder)folder;
+ (void) copyFromPath:(NSString *)fromPath toPath:(NSString *)toPath overriding:(BOOL)override;
+ (void) moveFromPath:(NSString *)fromPath toPath:(NSString *)toPath;
+ (void) copyFromBundleToLocal:(NSString *)named overriding:(BOOL)override;
+ (void) moveFromLocalToUser:(NSString *)named;
+ (BOOL) hasLocalNamed:(NSString *)named;
+ (BOOL) hasLocalNamed:(NSString *)named folder:(NPPDataFolder)folder;
+ (void) deleteLocalNamed:(NSString *)named;
+ (void) deleteLocalNamed:(NSString *)named folder:(NPPDataFolder)folder;
+ (void) deleteFolder:(NPPDataFolder)folder;
+ (void) deleteEverythingBeforeVersion:(NSString *)version build:(NSString *)build;
+ (NSDictionary *) attributesOfFile:(NSString *)named folder:(NPPDataFolder)folder;

// Global definitions. It's persistent and can keep the folder settings even across app opens.
+ (void) defineAppFolder:(NSString *)folderName;
+ (void) defineUserFolder:(NSString *)folderName;
+ (void) defineAppVersion:(NSString *)version build:(NSString *)build; // nil parameter means skip it.

@end