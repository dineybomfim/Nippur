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
