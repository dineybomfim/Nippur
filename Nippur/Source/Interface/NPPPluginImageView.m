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
static NSCache *nppImageViewCache(void)
{
	static NSCache *_default = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^(void)
	{
		_default = [[NSCache alloc] init];
		_default.countLimit = 1000;
		
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
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
	NSString *key = nil;
	
	switch (request.cachePolicy)
	{
		case NSURLRequestReloadIgnoringLocalCacheData:
		case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
			break;
		default:
			// Best performance with Base64 routine.
			key = [[[request URL] absoluteString] encodeBase64];
			break;
	}
	
	return key;
}

static UIImage *nppImageLoadCache(NSString *imageKey)
{
	NSCache *cache = nppImageViewCache();
	UIImage *image = [cache objectForKey:imageKey];
	
	return image;
}

static void nppImageSaveCache(NSString *imageKey, UIImage *image)
{
	NSCache *cache = nppImageViewCache();
	
	[cache setObject:image forKey:imageKey];
}

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

@implementation UIImageView(NPPImageView)

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

NPP_CATEGORY_PROPERTY(NPPConnector, connector, setConnector, OBJC_ASSOCIATION_RETAIN);

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
	[self loadURL:url placeholder:[info objectForKey:NPP_IV_PLACEHOLDER] override:YES];
}

- (void) loadURL:(NSString *)url placeholder:(UIImage *)image override:(BOOL)overriding
{
	// Cancelling previous loadings.
	if (overriding)
	{
		[NPPConnector cancelConnector:[self connector]];
	}
	
	if ([url hasPrefix:@"http"])
	{
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
		[request setHTTPShouldHandleCookies:YES];
		[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
		
		NSString *key = nppImageKey(request);
		UIImage *cache = nppImageLoadCache(key);
		
		if (cache != nil)
		{
			self.image = cache;
		}
		else
		{
			self.image = image;
			
			NPPConnector *conn = nil;
			conn = [NPPConnector connectorWithRequest:request completion:^(NPPConnector *connector)
			{
				UIImage *newImage = [UIImage imageWithData:connector.receivedData];
				
				if (newImage != nil)
				{
					nppImageSaveCache(key, newImage);
					
					//TODO Prevents older loadings to override new loadings.
					self.image = newImage;
				}
				
				[self setConnector:nil];
			 }];
			
			[self setConnector:conn];
		}
	}
	else
	{
		UIImage *localImage = nppImageFromFile(url);
		localImage = (localImage != nil) ? localImage : image;
		
		self.image = localImage;
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
