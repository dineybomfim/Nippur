/*
 *	NPPImageView+UIImageView.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 8/6/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPImage+UIImage.h"

//TODO
#if NPP_IOS
	#define NPP_IMAGE_VIEW			UIImageView
#else
	#define NPP_IMAGE_VIEW			NSImageView
#endif

typedef void (^NPPBlockImage)(NPP_ARC_UNSAFE NPPImage *image);

@interface UIImageView (NPPImageView)

- (void) loadURL:(NSString *)url completion:(NPPBlockImage)block;

/*!
 *					Loads image asynchronously from online URL or local path.
 *					This method first attempts to load a local cache and then, based on a minimum
 *					update interval it will try to reload/update the online URL if necessary.
 *
 *					The completion block will notify about the loaded image. This block is dispatched once
 *					when a final result is found, that means, 1) local cache within the minimum update
 *					interval or 2) a loaded imagem. It can return nil if it fails loading an image.
 */
- (void) loadURL:(NSString *)url
	 placeholder:(UIImage *)placeholder
		 loading:(UIView *)loading
	  completion:(NPPBlockImage)block;

+ (void) definePlaceholder:(NSString *)fileNamed;

@end