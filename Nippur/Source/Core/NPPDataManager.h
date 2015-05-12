/*
 *	NPPDataManager.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 02/27/12.
 *	Copyright 2012 db-in. All rights reserved.
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