/*
 *	NPPImageView+UIImageView.h
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