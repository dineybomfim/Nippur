/*
 *	NPPPluginImageView.h
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

#import "NPPPluginView.h"
#import "NPPPluginImage.h"

//TODO
#if NPP_IOS
	#define NPP_IMAGE_VIEW			UIImageView
#else
	#define NPP_IMAGE_VIEW			NSImageView
#endif

/*!
 *					This category can load online or offline images asynchronously. It is prepared to
 *					handle local caches and deal with online resources automatically.
 */
@interface UIImageView (NPPImageView)

/*!
 *					Act exactly like #loadURL:placeholder:override:#, but using the global defined
 *					placeholder image and using "overriding" YES.
 *
 *	@param			url
 *					A string with the final URL.
 *
 *	@see			loadURL:placeholder:override:
 */
- (void) loadURL:(NSString *)url;

/*!
 *					Loads image asynchronously from online URL or local path.
 *					This method use the persistent cache to handle previously downloaded images. The
 *					cache can be discarded at any time, depending on your application memory usage.
 *
 *					The cache is persistent, that means it will remain even if the application is closed
 *					by the user.
 *
 *	@param			url
 *					A string with the final URL.
 *
 *	@param			image
 *					The placeholder image to be used.
 *
 *	@param			overriding
 *					Defines if new calls can override older calls, that means the older call will be
 *					interrupted, without any cache generation.
 */
- (void) loadURL:(NSString *)url placeholder:(NPP_IMAGE *)image override:(BOOL)overriding;

/*!
 *					Defines a global placeholder to be used in all subsequent calls to #loadURL:#.
 *
 *	@param			image
 *					The placeholder image to be used.
 */
+ (void) definePlaceholder:(NPP_IMAGE *)image;

@end