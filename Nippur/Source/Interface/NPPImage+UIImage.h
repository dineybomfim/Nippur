/*
 *	NPPImage+UIImage.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 8/17/12.
 *	Copyright 2012 db-in. All rights reserved.
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