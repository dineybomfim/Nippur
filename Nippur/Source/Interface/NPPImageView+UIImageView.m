/*
 *	NPPImageView+UIImageView.m
 *	Nippur
 *	
 *	Created by Diney Bomfim on 8/6/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPImageView+UIImageView.h"

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

NPP_STATIC_READONLY(nppImageViewProperties, NSMutableDictionary);

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

- (void) loadURL:(NSString *)url completion:(NPPBlockImage)block
{
	NSMutableDictionary *info = nppImageViewProperties();
	[self loadURL:url placeholder:[info objectForKey:NPP_IV_PLACEHOLDER] loading:nil completion:block];
}

- (void) loadURL:(NSString *)url
	 placeholder:(UIImage *)placeholder
		 loading:(UIView *)loading
	  completion:(NPPBlockImage)block
{
	//TODO LOCAL CACHE
	
	UIImage *image = nppImageFromFile(url);
	image = (image != nil) ? image : placeholder;
	
	if ([url hasPrefix:@"http"])
	{
		self.image = image;
		//TODO CHECK IF is within update interval
		
		// IF NOT
		//TODO local cache
		
		// IF SO
		//TODO loading view
		//*
		[NPPConnector connectorWithURL:url
								method:NPPHTTPMethodGET
							   headers:nil
								  body:nil
							completion:^(NPPConnector *connector)
		{
			//TODO remove loading
		
			UIImage *image = [UIImage imageWithData:connector.receivedData];
			image = (image != nil) ? image : placeholder;
			
			//LOCAL CACHE
			self.image = image;
			//nppBlock(block, [image NPPImage]);
		}];
		/*/
		//*/
	}
	else
	{
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
