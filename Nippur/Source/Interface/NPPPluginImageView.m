/*
 *	NPPPluginImageView.m
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

#import "NPPPluginImageView.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_IV_PLACEHOLDER					@"placeholder"

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

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

NPP_STATIC_READONLY(NSMutableDictionary, nppImageViewProperties);
//NPP_STATIC_READONLY(nppImageViewCache, NSMutableDictionary);
static NSMutableDictionary *nppImageViewCache(void)
{
	static NSMutableDictionary *_default = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^(void)
				  {
					  _default = [[NSMutableDictionary alloc] init];
					  [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
																		object:nil
																		 queue:[NSOperationQueue mainQueue]
																	usingBlock:^(NSNotification *notification)
					   {
						   [_default removeAllObjects];
					   }];
				  });
	
	return _default;
}

static NSString *nppImageKey(NSURLRequest *request)
{
	// Best performance with Base64 routine.
	return [[[request URL] absoluteString] encodeBase64];
}
/*
 static UIImage *nppImageLoadCache(NSString *imageKey)
 {
	NSMutableDictionary *cache = nppImageViewCache();
	
	return [cache objectForKey:imageKey];
 }
 
 static void nppImageSaveCache(NSString *imageKey, UIImage *image)
 {
	NSMutableDictionary *cache = nppImageViewCache();
	
	[cache setObject:image forKey:imageKey];
 }
 /*/
static UIImage *nppImageLoadCache(NSString *imageKey)
{
	NSMutableDictionary *cache = nppImageViewCache();
	UIImage *image = [cache objectForKey:imageKey];
	
	if (image == nil)
	{
		image = [NPPDataManager loadFile:imageKey type:NPPDataTypeArchive folder:NPPDataFolderNippur];
		
		if (image != nil)
		{
			[cache setObject:image forKey:imageKey];
		}
	}
	
	return image;
}

static void nppImageSaveCache(NSString *imageKey, UIImage *image)
{
	[NPPDataManager saveFile:image name:imageKey type:NPPDataTypeArchive folder:NPPDataFolderNippur];
}
//*/

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

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
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

#pragma mark -
#pragma mark NPPImageView Category
#pragma mark -
//**********************************************************************************************************
//
//	NPPImageView Category
//
//**********************************************************************************************************

@implementation UIImageView (NPPImageView)

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

- (void) loadURL:(NSString *)url
{
	NSMutableDictionary *info = nppImageViewProperties();
	[self loadURL:url placeholder:[info objectForKey:NPP_IV_PLACEHOLDER] completion:nil];
}

- (void) loadURL:(NSString *)url placeholder:(UIImage *)placeholder completion:(NPPBlockImage)block
{
	UIImage *image = nil;
	
	if ([url hasPrefix:@"http"])
	{
		self.image = placeholder;
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
		[request setHTTPShouldHandleCookies:YES];
		[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
		[request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
		
		NSString *key = nppImageKey(request);
		UIImage *image = nppImageLoadCache(key);
		
		if (image != nil)
		{
			self.image = image;
			//nppBlock(block, [image NPPImage]);
		}
		else
		{
			NPPBlockVoid bgBlock = ^(void)
			{
				[NPPConnector connectorWithRequest:request completion:^(NPPConnector *connector)
				 {
					 UIImage *image = [UIImage imageWithData:connector.receivedData];
					 
					 if (image != nil)
					 {
						 nppImageSaveCache(key, image);
						 nppBlockMain(^(void){ self.image = image; });
						 //nppBlock(block, [image NPPImage]);
					 }
				 }];
			};
			
			nppBlockBG(bgBlock);
		}
	}
	else
	{
		UIImage *image = nppImageFromFile(url);
		image = (image != nil) ? image : placeholder;
		
		self.image = image;
		//nppBlock(block, [image NPPImage]);
	}
}

+ (void) definePlaceholder:(NSString *)fileNamed
{
	UIImage *image = nppImageFromFile(fileNamed);
	
	if (image != nil)
	{
		NSMutableDictionary *info = nppImageViewProperties();
		[info setObject:image forKey:NPP_IV_PLACEHOLDER];
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end
