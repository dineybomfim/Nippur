/*
 *	NPPImage+UIImage.h
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

#import "NPPInterfaceFunctions.h"
#import "NPPColor+UIColor.h"

#import <UIKit/UIKit.h>

//TODO
#if NPP_IOS
	#define NPP_IMAGE				UIImage
#else
	#define NPP_IMAGE				NSImage
#endif

// Single name or numeric # pattern. Starting at #1.
NPP_API UIImage *nppImageFromFile(NSString *named);
NPP_API NSArray *nppImagesFromFiles(NSString *namePattern);
NPP_API UIImageView *nppImageViewFromFile(NSString *namePattern);

@interface NPPImage : NPP_IMAGE
{
@private
	unsigned char				*_buffer;
	float						_nppScale;
	CGSize						_nppSize;
	CGColorSpaceRef				_cgColor;
	CGContextRef				_cgContext;
	CGImageRef					_coreImage;
}

@property (nonatomic, readonly) unsigned char *pixelBuffer;
@property (nonatomic, readonly) CGContextRef context;

- (id) initWithSize:(CGSize)size scale:(float)scale;
+ (NPPImage *) imageWithSize:(CGSize)size scale:(float)scale;

- (void) makeGrayscale;
- (void) makeAlphaMaskNegative:(BOOL)isNegative;
- (void) makeBoxBlur:(int)radius;
- (void) makeGaussianBlur:(int)radius;
- (void) makeCircleWithRadius:(int)radius usingNegative:(BOOL)isNegative;

- (NSArray *) processTemplateMatch:(NPPImage *)image;
- (NPPRGBA) processAverageColorInRect:(CGRect)rect;
- (NPPRGBA) processBiggestColorInRect:(CGRect)rect;

@end

@interface NPP_IMAGE(NPPImage)

- (NPPImage *) NPPImage;

- (UIImage *) imageNineSliced;
- (UIImage *) imageCroppedInRect:(CGRect)rect;
- (UIImage *) imageRotatedBy:(float)degrees;
- (UIImage *) imageScaledX:(float)scaleX andY:(float)scaleY;
- (UIImage *) imageFlippedHorizontal:(BOOL)horizontal vertical:(BOOL)vertical;
- (UIImage *) imageResized:(CGSize)size contentMode:(UIViewContentMode)mode;
- (UIImage *) imageTinted:(UIColor *)color;
- (UIImage *) imageMaskedBy:(UIImage *)mask usingNegative:(BOOL)isNegative;
- (UIImage *) imageBlendedWith:(UIImage *)topImage;

+ (UIImage *) imageWithColor:(UIColor *)color size:(CGSize)size;

// Starting at the center.
+ (UIImage *) imageWithRadialGradient:(CGSize)size start:(UIColor *)start end:(UIColor *)end;

// Starting from left to right.
+ (UIImage *) imageWithLinearGradient:(CGSize)size
								start:(UIColor *)start
								  end:(UIColor *)end
							   mirror:(BOOL)mirror;

@end

@interface NPP_IMAGE(NPPCipherImage)

- (NSString *) encodeJPEGWithBase64;
- (NSString *) encodePNGWithBase64;
+ (UIImage *) imageWithBase64:(NSString *)base64;

@end