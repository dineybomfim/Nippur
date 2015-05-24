/*
 *	NPPPluginImage.m
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

#import "NPPPluginImage.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_CIPHER_JPEG_64			@"data:image/jpeg;base64,"
#define NPP_CIPHER_PNG_64			@"data:image/png;base64,"

#define nppPixelGray(r,g,b)		((r) * 0.30f + (g) * 0.59f + (b) * 0.11f)

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

// Indicates if the context was created. Must call UIGraphicsEndImageContext(); to finish the context.
static BOOL nppGraphicsBeginImageContext(CGSize size, BOOL opaque, float scale)
{
	BOOL result = YES;
	
	if (size.width == 0.0f || size.height == 0.0f)
	{
		//@"WARNING: The view's width and height can't be zero."
		result = NO;
	}
	else
	{
		// Available for iOS 4 or later.
		UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
	}
	
	return result;
}

static NPPRGBA nppPixelGet(void **buffer, unsigned int i)
{
	NPPRGBA rgba;
	//*
	unsigned char *bufferPtr = (unsigned char *)buffer + (i * 4);
	
	rgba.r = *bufferPtr++;
	rgba.g = *bufferPtr++;
	rgba.b = *bufferPtr++;
	rgba.a = *bufferPtr++;
	/*/
	unsigned int *bufferPtr = (unsigned int *)buffer + i;
	
	rgba.r = (*bufferPtr >> 24) & 0xFF;
	rgba.g = (*bufferPtr >> 16) & 0xFF;
	rgba.b = (*bufferPtr >> 8) & 0xFF;
	rgba.a = (*bufferPtr >> 0) & 0xFF;
	//*/
	return rgba;
}

static void nppPixelSet(void **buffer, unsigned int i, NPPRGBA rgba)
{
	//*
	unsigned char *bufferPtr = (unsigned char *)buffer + (i * 4);
	
	*bufferPtr++ = rgba.r;
	*bufferPtr++ = rgba.g;
	*bufferPtr++ = rgba.b;
	*bufferPtr++ = rgba.a;
	/*/
	 unsigned int *bufferPtr = (unsigned int *)buffer + i;
	 
	 *bufferPtr = (rgba.r << 24) | (rgba.g << 16) | (rgba.b << 8) | (rgba.a << 0);
	 //*/
}

/*
static void nppPixelsFromImage(CGImageRef cgImage, unsigned char *buffer)
{
	CGBitmapInfo bitmapInfo;
	CGContextRef context;
	CGColorSpaceRef	color;
	CGRect rect;
	int width;
	int height;
	
	// Sets the size of image.
	width = CGImageGetWidth(cgImage);
	height = CGImageGetHeight(cgImage);
	rect = CGRectMake(0.0f, 0.0f, width, height);
	
	// Defines the information about bitmaps.
	bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
	
	// Always parse the image as RGBA by default.
	// So it sets the length to 4 bytes per pixel (RGBA8888), this is the default not optimized format.
	color = CGColorSpaceCreateDeviceRGB();
	context = CGBitmapContextCreate(buffer, width, height, 8, width * 4, color, bitmapInfo);
	
	// Draws the image in the context to further use the pixel data inside it.
	CGContextDrawImage(context, rect, cgImage);
	
	// Frees the datas.
	nppCFRelease(context);
	nppCFRelease(color);
}

static UIImage *nppImageWithPixels(CGSize size, float scale, unsigned char *buffer)
{
	int width = size.width * scale;
	int height = size.height * scale;
	UIImage *image = nil;
	CGDataProviderRef data = NULL;
	CGImageRef cgImage = NULL;
	CGContextRef context = NULL;
	CGColorSpaceRef color = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo info = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
	CGColorRenderingIntent intent = kCGRenderingIntentDefault;
	
	// Creates a CGImage from the pixel data.
	data = CGDataProviderCreateWithData(NULL, buffer, width * height * 4, NULL);
	cgImage = CGImageCreate(width, height, 8, 32, width * 4, color, info, data, NULL, YES, intent);
	
	// Starting image context and checks its creation.
	if (nppGraphicsBeginImageContext(size, NO, scale))
	{
		// Adjusts position and invert the image.
		// The image works renders upside-down compared to CGBitmapContext referential.
		context = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(context, 0.0f, height);
		CGContextScaleCTM(context, 1.0f, -1.0f);
		
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), cgImage);
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	
	// Frees the datas.
	nppCFRelease(data);
	nppCFRelease(color);
	nppCFRelease(cgImage);
	
	return image;
}
//*/
#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPImage()

- (void) resetContextWithSize:(CGSize)size scale:(float)scale;
- (void) renderImage;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Public Functions
//**************************************************
//	Public Functions
//**************************************************

UIImage *nppImageFromFile(NSString *named)
{
	UIImage *image = nil;
	
	if ([named length] > 0)
	{
		image = [UIImage imageWithContentsOfFile:nppMakePath(named)];
		image = (image != nil) ? image : [UIImage imageNamed:named];
	}
	
	return image;
}

NSArray *nppImagesFromFiles(NSString *namePattern)
{
	NSMutableArray *images = nil;
	UIImage *image = nil;
	NSRange range = [namePattern rangeOfString:@"#"];
	
	if (range.length > 0)
	{
		NSRange backRange = [namePattern rangeOfString:@"#" options:NSBackwardsSearch];
		range.length = 1 + backRange.location - range.location;
		
		// Creating the pattern.
		images = [NSMutableArray array];
		
		// Changing the name pattern.
		NSString *format = [NSString stringWithFormat:@"%%0%dd", (int)range.length];
		namePattern = [namePattern stringByReplacingCharactersInRange:range withString:format];
		
		// Looping through all files in folder.
		unsigned int i = 1;
		while (i)
		{
			if ((image = nppImageFromFile([NSString stringWithFormat:namePattern, i++])))
			{
				[images addObject:image];
			}
			else
			{
				break;
			}
		}
	}
	else if ((image = nppImageFromFile(namePattern)))
	{
		// Creating the pattern.
		images = [NSMutableArray arrayWithObject:image];
	}
	
	return images;
}

UIImageView *nppImageViewFromFile(NSString *namePattern)
{
	UIImageView *imageView = [[UIImageView alloc] init];
	NSArray *images = nppImagesFromFiles(namePattern);
	UIImage *firstImage = nil;
	
	if ([images count] > 1)
	{
		firstImage = [images firstObject];
		imageView.frame = (CGRect){ CGPointZero, [firstImage size] };
		imageView.image = [images lastObject];
		imageView.animationImages = images;
	}
	else if ([images count] == 1)
	{
		firstImage = [images firstObject];
		imageView.frame = (CGRect){ CGPointZero, [firstImage size] };
		imageView.image = firstImage;
	}
	
	return nppAutorelease(imageView);
}

#pragma mark -
#pragma mark Public Class
//**************************************************
//	Public Class
//**************************************************

@implementation NPPImage

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic pixelBuffer, context;

- (unsigned char *) pixelBuffer
{
	if (_buffer == NULL)
	{
		[self renderImage];
	}
	
	return _buffer;
}

- (CGContextRef) context
{
	return _cgContext;
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) initWithSize:(CGSize)size scale:(float)scale
{
	if ((self = [super init]))
	{
		scale = (scale > 0.0f) ? scale : [[UIScreen mainScreen] scale];
		size.width *= scale;
		size.height *= scale;
		[self resetContextWithSize:size scale:scale];
	}
	
	return self;
}

+ (NPPImage *) imageWithSize:(CGSize)size scale:(float)scale
{
	NPPImage *image = [[NPPImage alloc] initWithSize:size scale:scale];
	
	return nppAutorelease(image);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) resetContextWithSize:(CGSize)size scale:(float)scale
{
	// Setting the current size and scale.
	_nppScale = scale;
	_nppSize.width = size.width;
	_nppSize.height = size.height;
	
	// The scale must come from the property, because here the final scale is desired.
	int width = _nppSize.width;
	int height = _nppSize.height;
	CGBitmapInfo info = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
	
	// The context can be reset multiple times. Everytime the context reset, the buffer is cleared and
	// all the previous change will be lost. This is a way to clean up the image buffer.
	nppFree(_buffer);
	nppCFRelease(_cgContext);
	nppCFRelease(_cgColor);
	
	_buffer = calloc(_nppSize.width * _nppSize.height, NPP_SIZE_UCHAR * 4);
	_cgColor = CGColorSpaceCreateDeviceRGB();
	_cgContext = CGBitmapContextCreate(_buffer, width, height, 8, width * 4, _cgColor, info);
	
	// Flips the Core Graphics pixel order and translates to the rect origin.
	//CGContextTranslateCTM(_cgContext, 0.0f, height);
	//CGContextScaleCTM(_cgContext, scale, -scale);
	//CGContextSetInterpolationQuality(_cgContext, kCGInterpolationNone);
	//CGContextSetShouldAntialias(_cgContext, NO);
}

- (void) renderImage
{
	if (_buffer == NULL)
	{
		CGImageRef cgImage = [super CGImage];
		CGSize size = (CGSize){ CGImageGetWidth(cgImage), CGImageGetHeight(cgImage) };
		
		// Updates the bitmap context.
		[self resetContextWithSize:size scale:[super scale]];
		
		// Draws the image in the context to further use the pixel data inside it.
		CGContextDrawImage(_cgContext, (CGRect){ CGPointZero, _nppSize }, cgImage);
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) makeGrayscale
{
	if (_buffer == NULL)
	{
		[self renderImage];
	}
	
	NPPRGBA rgba;
	unsigned int i;
	unsigned int length = _nppSize.width * _nppSize.height;
	
	// Looping through every pixel.
	for (i = 0; i < length; ++i)
	{
		rgba = nppPixelGet((void **)_buffer, i);
		
		rgba.r = nppPixelGray(rgba.r, rgba.g, rgba.b);
		rgba.g = rgba.r;
		rgba.b = rgba.r;
		rgba.a = 255;
		
		nppPixelSet((void **)_buffer, i, rgba);
	}
	
	/*
	unsigned char gray;
	unsigned int i;
	unsigned int length = _size.width * _size.height * NPP_SIZE_UCHAR * 4;
	
	for (i = 0; i < length; i += 4)
	{
		gray = nppPixelGray(_buffer[i], _buffer[i + 1], _buffer[i + 2]);
		_buffer[i] = gray;
		_buffer[i + 1] = gray;
		_buffer[i + 2] = gray;
	}
	//*/
}

- (void) makeAlphaMaskNegative:(BOOL)isNegative
{
	if (_buffer == NULL)
	{
		[self renderImage];
	}
	
	NPPRGBA rgba;
	unsigned int i;
	unsigned int length = _nppSize.width * _nppSize.height;
	
	// Looping through every pixel.
	for (i = 0; i < length; ++i)
	{
		rgba = nppPixelGet((void **)_buffer, i);
		rgba = (NPPRGBA){ 0, 0, 0, (isNegative) ? 255 - rgba.a : rgba.a };
		
		nppPixelSet((void **)_buffer, i, rgba);
	}
}

- (void) makeBoxBlur:(int)radius
{
	if (_buffer == NULL)
	{
		[self renderImage];
	}
	
	//*
	int w = _nppSize.width;
	int h = _nppSize.height;
	
	if (radius < 1)
	{
		return;
	}
	
	int wm = w - 1;
	int hm = h - 1;
	int wh = w * h;
	int div = radius + radius + 1;
	unsigned char *r = calloc(wh, NPP_SIZE_UCHAR);
	unsigned char *g = calloc(wh, NPP_SIZE_UCHAR);
	unsigned char *b = calloc(wh, NPP_SIZE_UCHAR);
	int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
	int *vMIN = calloc(MAX(w, h), NPP_SIZE_INT);
	int *vMAX = calloc(MAX(w, h), NPP_SIZE_INT);
	
	unsigned char *dv = calloc(256 * div, NPP_SIZE_UCHAR);
	for ( i =0; i < 256 * div; ++i)
	{
		dv[i] = (i / div);
	}
	
	yw = yi = 0;
	
	for (y = 0; y < h; ++y)
	{
		rsum = gsum = bsum = 0;
		
		for(i = -radius; i <= radius; ++i)
		{
			p = (yi + MIN(wm, MAX(i,0))) * 4;
			rsum += _buffer[p];
			gsum += _buffer[p + 1];
			bsum += _buffer[p + 2];
		}
		
		for (x = 0; x < w; ++x)
		{
			r[yi] = dv[rsum];
			g[yi] = dv[gsum];
			b[yi] = dv[bsum];
			
			if(y == 0)
			{
				vMIN[x] = MIN(x + radius + 1, wm);
				vMAX[x] = MAX(x - radius, 0);
			}
			p1 = (yw + vMIN[x]) * 4;
			p2 = (yw + vMAX[x]) * 4;
			
			rsum += _buffer[p1] - _buffer[p2];
			gsum += _buffer[p1 + 1] - _buffer[p2 + 1];
			bsum += _buffer[p1 + 2] - _buffer[p2 + 2];
			
			++yi;
		}
		
		yw += w;
	}
	
	for (x = 0; x < w; ++x)
	{
		rsum = gsum = bsum = 0;
		yp = -radius * w;
		
		for(i = -radius; i <= radius; ++i)
		{
			yi = MAX(0, yp) + x;
			rsum += r[yi];
			gsum += g[yi];
			bsum += b[yi];
			yp += w;
		}
		
		yi = x;
		
		for (y = 0; y < h; ++y)
		{
			_buffer[yi * 4] = dv[rsum];
			_buffer[yi * 4 + 1] = dv[gsum];
			_buffer[yi * 4 + 2] = dv[bsum];
			
			if(x == 0)
			{
				vMIN[y] = MIN(y + radius + 1, hm) * w;
				vMAX[y] = MAX(y - radius, 0) * w;
			}
			p1 = x + vMIN[y];
			p2 = x + vMAX[y];
			
			rsum += r[p1] - r[p2];
			gsum += g[p1] - g[p2];
			bsum += b[p1] - b[p2];
			
			yi += w;
		}
	}
	
	free(r);
	free(g);
	free(b);
	
	free(vMIN);
	free(vMAX);
	free(dv);
	
	
	/*/
	
	//size must be an odd integer
	int size = radius * self.scale;
	if (size % 2 == 0)
	{
		++size;
	}
	
	//create image buffers
	vImage_Buffer bufferIn, bufferOut;
	bufferIn.width = bufferOut.width = _nppSize.width;
	bufferIn.height = bufferOut.height = _nppSize.height;
	bufferIn.rowBytes = bufferOut.rowBytes = _nppSize.width * 4;
	bufferIn.data = _buffer;
	bufferOut.data = _buffer;
	
	vImageBoxConvolve_ARGB8888(&bufferIn, &bufferOut, NULL, 0, 0, size, size, NULL, kvImageEdgeExtend);
	//*/
}

- (void) makeGaussianBlur:(int)radius
{
	if (_buffer == NULL)
	{
		[self renderImage];
	}
	
	int i;
	int width = _nppSize.width;
	int height = _nppSize.height;
	
	// Constants
	const int wm = width - 1;
	const int hm = height - 1;
	const int wh = width * height;
	const int div = radius + radius + 1;
	const int r1 = radius + 1;
	const int divsum = ((div + 1) >> 1) * ((div + 1) >> 1);
	
	// Small buffers
	int stack[div*3];
	memset(stack, 0, div * 3 * NPP_SIZE_INT);
	
	int vmin[MAX(width,height)];
	memset(vmin, 0, MAX(width,height) * NPP_SIZE_INT);
	
	// Large buffers
	int *r = calloc(wh, NPP_SIZE_INT);
	int *g = calloc(wh, NPP_SIZE_INT);
	int *b = calloc(wh, NPP_SIZE_INT);
	
	const size_t dvcount = 256 * divsum;
	int *dv = calloc(dvcount, NPP_SIZE_INT);
	
	for (i = 0; i < dvcount; ++i)
	{
		dv[i] = (i / divsum);
	}
	
	// Variables
	int x, y;
	int *sir;
	int routsum,goutsum,boutsum;
	int rinsum,ginsum,binsum;
	int rsum, gsum, bsum, p, yp;
	int stackpointer;
	int stackstart;
	int rbs;
	
	int yw = 0, yi = 0;
	for (y = 0; y < height; ++y)
	{
		rinsum = ginsum = binsum = routsum = goutsum = boutsum = rsum = gsum = bsum = 0;
		
		for(i = -radius; i <= radius; ++i)
		{
			sir = &stack[(i + radius)*3];
			int offset = (yi + MIN(wm, MAX(i, 0)))*4;
			sir[0] = _buffer[offset];
			sir[1] = _buffer[offset + 1];
			sir[2] = _buffer[offset + 2];
			
			rbs = r1 - abs(i);
			rsum += sir[0] * rbs;
			gsum += sir[1] * rbs;
			bsum += sir[2] * rbs;
			if (i > 0)
			{
				rinsum += sir[0];
				ginsum += sir[1];
				binsum += sir[2];
			}
			else
			{
				routsum += sir[0];
				goutsum += sir[1];
				boutsum += sir[2];
			}
		}
		stackpointer = radius;
		
		for (x = 0; x < width; ++x)
		{
			r[yi] = dv[rsum];
			g[yi] = dv[gsum];
			b[yi] = dv[bsum];
			
			rsum -= routsum;
			gsum -= goutsum;
			bsum -= boutsum;
			
			stackstart = stackpointer - radius + div;
			sir = &stack[(stackstart % div)*3];
			
			routsum -= sir[0];
			goutsum -= sir[1];
			boutsum -= sir[2];
			
			if (y == 0)
			{
				vmin[x] = MIN(x + radius + 1, wm);
			}
			
			int offset = (yw + vmin[x]) * 4;
			sir[0] = _buffer[offset];
			sir[1] = _buffer[offset + 1];
			sir[2] = _buffer[offset + 2];
			rinsum += sir[0];
			ginsum += sir[1];
			binsum += sir[2];
			
			rsum += rinsum;
			gsum += ginsum;
			bsum += binsum;
			
			stackpointer = (stackpointer + 1) % div;
			sir = &stack[(stackpointer % div)*3];
			
			routsum += sir[0];
			goutsum += sir[1];
			boutsum += sir[2];
			
			rinsum -= sir[0];
			ginsum -= sir[1];
			binsum -= sir[2];
			
			++yi;
		}
		
		yw += width;
	}
	
	for (x = 0; x < width; ++x)
	{
		rinsum = ginsum = binsum = routsum = goutsum = boutsum = rsum = gsum = bsum = 0;
		yp = -radius*width;
		
		for(i = -radius; i <= radius; ++i)
		{
			yi = MAX(0, yp) + x;
			
			sir = &stack[(i + radius)*3];
			
			sir[0] = r[yi];
			sir[1] = g[yi];
			sir[2] = b[yi];
			
			rbs = r1 - abs(i);
			
			rsum += r[yi]*rbs;
			gsum += g[yi]*rbs;
			bsum += b[yi]*rbs;
			
			if (i > 0)
			{
				rinsum += sir[0];
				ginsum += sir[1];
				binsum += sir[2];
			}
			else
			{
				routsum += sir[0];
				goutsum += sir[1];
				boutsum += sir[2];
			}
			
			if (i < hm)
			{
				yp += width;
			}
		}
		yi = x;
		stackpointer = radius;
		
		for (y = 0; y < height; ++y)
		{
			int offset = yi * 4;
			_buffer[offset]	 = dv[rsum];
			_buffer[offset + 1] = dv[gsum];
			_buffer[offset + 2] = dv[bsum];
			rsum -= routsum;
			gsum -= goutsum;
			bsum -= boutsum;
			
			stackstart = stackpointer - radius + div;
			sir = &stack[(stackstart % div)*3];
			
			routsum -= sir[0];
			goutsum -= sir[1];
			boutsum -= sir[2];
			
			if (x == 0)
			{
				vmin[y] = MIN(y + r1, hm)*width;
			}
			p = x + vmin[y];
			
			sir[0] = r[p];
			sir[1] = g[p];
			sir[2] = b[p];
			
			rinsum += sir[0];
			ginsum += sir[1];
			binsum += sir[2];
			
			rsum += rinsum;
			gsum += ginsum;
			bsum += binsum;
			
			stackpointer = (stackpointer + 1) % div;
			sir = &stack[stackpointer*3];
			
			routsum += sir[0];
			goutsum += sir[1];
			boutsum += sir[2];
			
			rinsum -= sir[0];
			ginsum -= sir[1];
			binsum -= sir[2];
			
			yi += width;
		}
	}
	
	free(r);
	free(g);
	free(b);
	free(dv);
}

- (void) makeCircleWithRadius:(int)radius usingNegative:(BOOL)isNegative
{
	if (_buffer == NULL)
	{
		[self renderImage];
	}
	
	radius *= self.scale;
	radius *= 1.4f;
	
	NPPRGBA rgba;
	unsigned int i = 0;
	unsigned int x = 0, y = 0;
	unsigned int dx = 0, dy = 0;
	unsigned int distanceSquared = 0;
	
	// Constants.
	const int centerX = (int)floorf(_nppSize.width * 0.5f);
	const int centerY = (int)floorf(_nppSize.height * 0.5f);
	const int radiusSquared = (int)powf(radius, 2.0f) * 0.5f;
	
	for (y = 0; y < _nppSize.height; ++y)
	{
		for (x = 0; x < _nppSize.width; ++x)
		{
			dx = x - centerX;
			dy = y - centerY;
			distanceSquared = (dx * dx) + (dy * dy);
			
			if ((isNegative && distanceSquared <= radiusSquared) ||
				(!isNegative && distanceSquared > radiusSquared))
			{
				i = x + (y * _nppSize.width);
				rgba = (NPPRGBA){ 0, 0, 0, 0 };
				
				nppPixelSet((void **)_buffer, i, rgba);
			}
		}
	}
}

- (NSArray *) processTemplateMatch:(NPPImage *)image
{
	if (_buffer == NULL)
	{
		[self renderImage];
	}
	
	//TODO template match like OpenCV.
	
	return nil;
}

- (NPPRGBA) processAverageColorInRect:(CGRect)rect
{
	if (_buffer == NULL)
	{
		[self renderImage];
	}
	
	NPPRGBA rgba;
	unsigned int i;
	unsigned int y, x;
	unsigned int block, element;
	unsigned int blockCount, elementCount;
	unsigned long long color[4] = { 0, 0, 0, 0 };
	unsigned long long total;
	
	// Clamps the rect to bounds.
	rect.origin.x = NPPClamp(rect.origin.x, 0, _nppSize.width);
	rect.origin.y = NPPClamp(rect.origin.y, 0, _nppSize.height);
	rect.size.width = NPPClamp(rect.size.width, 0, _nppSize.width - rect.origin.x);
	rect.size.height = NPPClamp(rect.size.height, 0, _nppSize.height - rect.origin.y);
	
	// Initial settings.
	y = rect.origin.y;
	x = rect.origin.x;
	blockCount = rect.origin.y + rect.size.height;
	elementCount = rect.origin.x + rect.size.width;
	total = rect.size.width * rect.size.height;
	
	// Looping through every pixel in rect.
	for (block = y; block < blockCount; ++block)
	{
		for (element = x; element < elementCount; ++element)
		{
			i = element + (block * _nppSize.width);
			rgba = nppPixelGet((void **)_buffer, i);
			
			color[0] += rgba.r;
			color[1] += rgba.g;
			color[2] += rgba.b;
			color[3] += rgba.a;
		}
	}
	
	// Calculates the average color
	if (total > 0)
	{
		color[0] /= total, color[1] /= total, color[2] /= total, color[3] /= total;
	}
	
	// Creates the final RGBA color.
	rgba = nppRGBAMake(color[0], color[1], color[2], color[3]);
	
	return rgba;
}

- (NPPRGBA) processBiggestColorInRect:(CGRect)rect
{
	if (_buffer == NULL)
	{
		[self renderImage];
	}
	
	NPPRGBA rgba;
	unsigned int i;
	unsigned int y, x;
	unsigned int block, element;
	unsigned int blockCount, elementCount;
	
	NSString *name = nil;
	NSNumber *count = nil;
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	// Clamps the rect to bounds.
	rect.origin.x = NPPClamp(rect.origin.x, 0, _nppSize.width);
	rect.origin.y = NPPClamp(rect.origin.y, 0, _nppSize.height);
	rect.size.width = NPPClamp(rect.size.width, 0, _nppSize.width - rect.origin.x);
	rect.size.height = NPPClamp(rect.size.height, 0, _nppSize.height - rect.origin.y);
	
	// Initial settings.
	y = rect.origin.y;
	x = rect.origin.x;
	blockCount = rect.origin.y + rect.size.height;
	elementCount = rect.origin.x + rect.size.width;
	
	// Looping through every pixel in rect.
	for (block = y; block < blockCount; ++block)
	{
		for (element = x; element < elementCount; ++element)
		{
			i = element + (block * _nppSize.width);
			rgba = nppPixelGet((void **)_buffer, i);
			
			name = [NSString stringWithFormat:@"%i %i %i", rgba.r, rgba.g, rgba.b];
			count = [dict objectForKey:name];
			[dict setObject:[NSNumber numberWithUnsignedInt:[count unsignedIntValue] + 1] forKey:name];
		}
	}
	
	// Finding the most repetitive pattern.
	unsigned int biggestValue = 0;
	NSString *biggestIndex = nil;
	for (name in dict)
	{
		count = [dict objectForKey:name];
		
		if ([count unsignedIntValue] > biggestValue)
		{
			biggestValue = [count unsignedIntValue];
			biggestIndex = name;
		}
	}
	
	// Creates the final RGBA color.
	NSArray *colors = [biggestIndex componentsSeparatedByString:@" "];
	rgba = nppRGBAMake([[colors objectAtIndex:0] intValue],
					   [[colors objectAtIndex:1] intValue],
					   [[colors objectAtIndex:2] intValue],
					   255);
	
	return rgba;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

//*
- (CGSize) size
{
	if (_buffer == NULL)
	{
		[self renderImage];
	}
	
	float scale = self.scale;
	CGSize size = _nppSize;
	size.width /= scale;
	size.height /= scale;
	
	return size;
}

- (CGFloat) scale
{
	return (_nppScale > 0.0f) ? _nppScale : [super scale];
}
//*/

- (CGImageRef) CGImage
{
	if (_buffer == NULL)
	{
		[self renderImage];
	}
	
	/*
	int width = _nppSize.width;
	int height = _nppSize.height;
	
	CGColorSpaceRef color;
	CGDataProviderRef provider;
	CGBitmapInfo info = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
	CGColorRenderingIntent intent = kCGRenderingIntentDefault;
	
	// Creates a CGImage from the pixel data.
	color = CGColorSpaceCreateDeviceRGB();
	provider = CGDataProviderCreateWithData(NULL, _buffer, width * height * 4, NULL);
	//context = CGBitmapContextCreate(_buffer, width, height, 8, width * 4, color, info);
	
	nppCFRelease(_coreImage);
	_coreImage = CGImageCreate(width, height, 8, 32, width * 4, color, info, provider, NULL, YES, intent);
	//_coreImage = CGBitmapContextCreateImage(context);
	
	// Frees the datas.
	nppCFRelease(provider);
	nppCFRelease(color);
	/*/
	nppCFRelease(_coreImage);
	_coreImage = CGBitmapContextCreateImage(_cgContext);
	//*/
	
	return _coreImage;
}

+ (UIImage *) imageNamed:(NSString *)name
{
	return nppAutorelease([[self alloc] initWithContentsOfFile:nppMakePath(name)]);
}

+ (UIImage *) imageWithContentsOfFile:(NSString *)path
{
	return nppAutorelease([[self alloc] initWithContentsOfFile:path]);
}

+ (UIImage *) imageWithData:(NSData *)data
{
	return nppAutorelease([[self alloc] initWithData:data]);
}

+ (UIImage *) imageWithData:(NSData *)data scale:(CGFloat)scale
{
	return nppAutorelease([[self alloc] initWithData:data scale:scale]);
}

+ (UIImage *) imageWithCGImage:(CGImageRef)cgImage
{
	return nppAutorelease([[self alloc] initWithCGImage:cgImage]);
}

+ (UIImage *) imageWithCGImage:(CGImageRef)cgImage
						 scale:(CGFloat)scale
				   orientation:(UIImageOrientation)orientation
{
	return nppAutorelease([[self alloc] initWithCGImage:cgImage scale:scale orientation:orientation]);
}

+ (UIImage *) imageWithCIImage:(CIImage *)ciImage
{
	return nppAutorelease([[self alloc] initWithCIImage:ciImage]);
}

+ (UIImage *) imageWithCIImage:(CIImage *)ciImage
						 scale:(CGFloat)scale
				   orientation:(UIImageOrientation)orientation
{
	return nppAutorelease([[self alloc] initWithCIImage:ciImage scale:scale orientation:orientation]);
}

- (void) dealloc
{
	nppFree(_buffer);
	nppCFRelease(_cgContext);
	nppCFRelease(_cgColor);
	nppCFRelease(_coreImage);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end

#pragma mark -
#pragma mark Categories
#pragma mark -
//**********************************************************************************************************
//
//	Categories
//
//**********************************************************************************************************

@implementation NPP_IMAGE (NPPImage)

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

- (NPPImage *) NPPImage
{
	NPPImage *image = (NPPImage *)[[NPPImage alloc] initWithCGImage:self.CGImage
															  scale:self.scale
														orientation:self.imageOrientation];
	
	return nppAutorelease(image);
}

- (UIImage *) imageNineSliced
{
	CGSize size = self.size;
	
	// Takes the roudend half size.
	int halfW = (int)(size.width + 1) >> 1;
	int halfH = (int)(size.height + 1) >> 1;
	
	// The two pixels in the middle will be stretched. Both horizontally and vertically.
	UIEdgeInsets edge = UIEdgeInsetsMake(halfH - 1, halfW - 1, halfH + 1, halfW + 1);
	
	return [self resizableImageWithCapInsets:edge];
}

- (UIImage *) imageCroppedInRect:(CGRect)rect
{
	UIImageOrientation orientation = self.imageOrientation;
	float scale = self.scale;
	rect.origin.x *= scale;
	rect.origin.y *= scale;
	rect.size.width *= scale;
	rect.size.height *= scale;
	
	CGImageRef crop = CGImageCreateWithImageInRect([self CGImage], rect);
	UIImage *newImage = [UIImage imageWithCGImage:crop scale:scale orientation:orientation];
	CGImageRelease(crop);
	
	return newImage;
}

- (UIImage *) imageRotatedBy:(float)degrees
{
	UIImage *image = nil;
	CGSize size =  self.size;
	float scale = self.scale;
	CGContextRef context = NULL;
	CGImageRef cgImage = [self CGImage];
	
	// Starting image context and checks its creation.
	if (nppGraphicsBeginImageContext(size, NO, scale))
	{
		context = UIGraphicsGetCurrentContext();
		
		// Unflip the CGImage, a small workaround as CGImages are upside-down.
		CGContextTranslateCTM(context, 0.0f, size.height);
		CGContextScaleCTM(context, 1.0f, -1.0f);
		
		// Rotating the image by its central position.
		CGContextTranslateCTM(context, size.width * 0.5f, size.height * 0.5f);
		CGContextRotateCTM(context, NPPDegreesToRadians(degrees));
		CGContextTranslateCTM(context, -size.width * 0.5f, -size.height * 0.5f);
		
		// Clears and Draws the image in the context to further use the pixel data inside it.
		CGContextClearRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), cgImage);
		
		image = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
	}
	
	return image;
}

- (UIImage *) imageScaledX:(float)scaleX andY:(float)scaleY
{
	UIImage *image = nil;
	CGSize size =  self.size;
	float scale = self.scale;
	CGContextRef context = NULL;
	CGImageRef cgImage = [self CGImage];
	
	size.width *= fabsf(scaleX);
	size.height *= fabsf(scaleY);
	
	// Starting image context and checks its creation.
	if (nppGraphicsBeginImageContext(size, NO, scale))
	{
		context = UIGraphicsGetCurrentContext();
		
		// Unflip the CGImage, a small workaround as CGImages are upside-down.
		CGContextTranslateCTM(context, 0.0f, size.height);
		CGContextScaleCTM(context, 1.0f, -1.0f);
		
		if (scaleX < 0.0f)
		{
			CGContextTranslateCTM(context, size.width, 0.0f);
			CGContextScaleCTM(context, scaleX, 1.0f);
		}
		
		if (scaleY < 0.0f)
		{
			CGContextTranslateCTM(context, 0.0f, size.height);
			CGContextScaleCTM(context, 1.0f, scaleY);
		}
		
		// Clears and Draws the image in the context to further use the pixel data inside it.
		CGContextClearRect(context, CGRectMake(0.0f, 0.0f, size.width, size.height));
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), cgImage);
		
		image = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
	}
	
	return image;
}

- (UIImage *) imageFlippedHorizontal:(BOOL)horizontal vertical:(BOOL)vertical
{
	return [self imageScaledX:(horizontal) ? -1.0f : 1.0f andY:(vertical) ? - 1.0f : 1.0f];
}

- (UIImage *) imageResized:(CGSize)size contentMode:(UIViewContentMode)mode
{
	UIImage *image = nil;
	/*
	UIImageView *imageView = [[UIImageView alloc] initWithImage:self];
	imageView.contentMode = mode;
	imageView.size = size;
	
	image = [imageView snapshot];
	
	nppRelease(imageView);
	/*/
	if (nppGraphicsBeginImageContext(size, NO, 0.0f))
	{
		[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
		image = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
	}
	//*/
	
	return image;
}

- (UIImage *) imageTinted:(UIColor *)color
{
	UIImage *image = nil;
	CGSize size = self.size;
	CGContextRef context = NULL;
	CGRect area = CGRectMake(0, 0, size.width, size.height);
	float scale = self.scale;
	
	// Starting image context and checks its creation.
	if (nppGraphicsBeginImageContext(size, NO, scale))
	{
		// Redrawing the image in the context.
		[self drawInRect:area];
		
		// Setting the blend mode.
		context = UIGraphicsGetCurrentContext();
		CGContextSetBlendMode(context, kCGBlendModeSourceIn);
		
		// Fills the image with the tint color.
		CGContextSetFillColorWithColor(context, [color CGColor]);
		CGContextFillRect(context, area);
		
		// Gets the final image.
		image = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
	}
	
	return image;
}
//*
- (UIImage *) imageMaskedBy:(UIImage *)mask usingNegative:(BOOL)isNegative
{
	CGImageRef cgMask = [mask CGImage];
	CGBitmapInfo bitmapInfo;
	CGContextRef context;
	CGColorSpaceRef	colorSpace;
	CGRect rect;
	int width;
	int height;
	unsigned char *buffer;
	int rowLength;
	
	// Sets the size of image.
	width = (int)CGImageGetWidth(cgMask);
	height = (int)CGImageGetHeight(cgMask);
	rect = CGRectMake(0.0f, 0.0f, width, height);
	
	// Defines the information about bitmaps.
	bitmapInfo = (CGBitmapInfo)kCGImageAlphaOnly;//kCGBitmapAlphaInfoMask
	
	buffer = calloc(width * height, NPP_SIZE_UCHAR * 4);
	rowLength = ((width + 4 - 1) / 4) * 4;
	
	// The alpha mask specific requires that mask be in DeviceGray color space.
	colorSpace = CGColorSpaceCreateDeviceGray();
	context = CGBitmapContextCreate(buffer, width, height, 8, rowLength, colorSpace, bitmapInfo);
	
	// Clears and Draws the image in the context to further use the pixel data inside it.
	CGContextClearRect(context, rect);
	CGContextDrawImage(context, rect, cgMask);
	
	// Invert each alpha pixel value.
	if (isNegative)
	{
		unsigned int x, y;
		unsigned char value;
		
		for (y = 0; y < height; ++y)
		{
			for (x = 0; x < width; ++x)
			{
				value = buffer[y * rowLength + x];
				value = 255 - value;
				buffer[y * rowLength + x] = value;
			}
		}
	}
	
	CGImageRef alphaMask = CGBitmapContextCreateImage(context);
	CGImageRef cgImage = CGImageCreateWithMask(self.CGImage, alphaMask);
	UIImage *image = [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
	
	// Frees the data.
	nppFree(buffer);
	nppCFRelease(alphaMask);
	nppCFRelease(context);
	nppCFRelease(colorSpace);
	nppCFRelease(cgImage);
	
	return image;
}
/*/
- (UIImage *) imageMaskedBy:(UIImage *)maskImage usingNegative:(BOOL)isNegative
{
	CGColorSpaceRef graySpace = CGColorSpaceCreateDeviceGray();
	CGImageRef maskRef = CGImageCreateCopyWithColorSpace(maskImage.CGImage, graySpace);
	
	CGImageRef resultRef = CGImageCreateWithMask(self.CGImage, maskRef);
	UIImage *image = [UIImage imageWithCGImage:resultRef scale:self.scale orientation:self.imageOrientation];
	
	nppCFRelease(resultRef);
	nppCFRelease(maskRef);
	
	return image;
}
//*/
- (UIImage *) imageBlendedWith:(UIImage *)topImage
{
	UIImage *image = nil;
	CGSize sizeA = self.size;
	CGSize sizeB = topImage.size;
	CGSize mergedSize = CGSizeMake(MAX(sizeA.width, sizeB.width), MAX(sizeA.height, sizeB.height));
	CGFloat mergedScale = MAX(self.scale, topImage.scale);
	CGRect frame = CGRectZero;
	
	// Starting image context and checks its creation.
	if (nppGraphicsBeginImageContext(mergedSize, NO, mergedScale))
	{
		// Blend two images.
		/*
		[self drawAtPoint:CGPointZero];
		[topImage drawAtPoint:CGPointZero];
		//[topImage drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:0.0f];
		/*/
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(context, 0.0f, mergedSize.height);
		CGContextScaleCTM(context, 1.0f, -1.0f);
		
		frame = CGRectMake(0.0f, 0.0f, sizeA.width, sizeA.height);
		CGContextDrawImage(context, frame, self.CGImage);
		
		frame = CGRectMake(0.0f, sizeA.height - sizeB.height, sizeB.width, sizeB.height);
		CGContextDrawImage(context, frame, topImage.CGImage);
		//*/
		image = UIGraphicsGetImageFromCurrentImageContext();
		
		// CG clean up.
		UIGraphicsEndImageContext();
	}
	
	return image;
}

+ (UIImage *) imageWithColor:(UIColor *)color size:(CGSize)size
{
	UIImage *image = nil;
	CGContextRef context = NULL;
	CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
	
	// Starting image context and checks its creation.
	if (nppGraphicsBeginImageContext(size, NO, 0.0f))
	{
		context = UIGraphicsGetCurrentContext();
		
		CGContextSetFillColorWithColor(context, [color CGColor]);
		CGContextFillRect(context, rect);
		
		// Gets the autoreleased image.
		image = UIGraphicsGetImageFromCurrentImageContext();
		
		// CG clean up.
		UIGraphicsEndImageContext();
	}
	
	return image;
}

+ (UIImage *) imageWithRadialGradient:(CGSize)size start:(UIColor *)start end:(UIColor *)end
{
	UIImage *image = nil;
	CGContextRef context = NULL;
	NPPvec4 srgba = nppColorFromUIColor(start);
	NPPvec4 ergba = nppColorFromUIColor(end);
	
	// Starting image context and checks its creation.
	if (nppGraphicsBeginImageContext(size, NO, 0.0f))
	{
		context = UIGraphicsGetCurrentContext();
		
		// Settings the gradient properties.
		size_t count = 2;
		CGFloat points[2] = { 0.3f, 1.0f };
		CGFloat colors[8] = { srgba.r, srgba.g, srgba.b, srgba.a, ergba.r, ergba.g, ergba.b, ergba.a };
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, points, count);
		
		// Drawing gradient.
		CGGradientDrawingOptions options = kCGGradientDrawsAfterEndLocation;
		CGPoint center = CGPointMake(size.width / 2, size.height/2);
		float radius = MIN(size.width , size.height);
		CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, options);
		
		// Gets the autoreleased image.
		image = UIGraphicsGetImageFromCurrentImageContext();
		
		// CG clean up.
		CGColorSpaceRelease(rgb);
		CGGradientRelease(gradient);
		UIGraphicsEndImageContext();
	}
	
	return image;
}

+ (UIImage *) imageWithLinearGradient:(CGSize)size
								start:(UIColor *)start
								  end:(UIColor *)end
							   mirror:(BOOL)mirror
{
	UIImage *image = nil;
	CGContextRef context = NULL;
	NPPvec4 srgba = nppColorFromUIColor(start);
	NPPvec4 ergba = nppColorFromUIColor(end);
	
	// Starting image context and checks its creation.
	if (nppGraphicsBeginImageContext(size, NO, 0.0f))
	{
		context = UIGraphicsGetCurrentContext();
		
		// Settings the gradient properties.
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = NULL;
		
		if (!mirror)
		{
			size_t count = 2;
			CGFloat points[2] = { 0.0f, 1.0f };
			CGFloat colors[8] = { srgba.r, srgba.g, srgba.b, srgba.a, ergba.r, ergba.g, ergba.b, ergba.a };
			gradient = CGGradientCreateWithColorComponents(rgb, colors, points, count);
		}
		else
		{
			size_t count = 3;
			CGFloat points[3] = { 0.0f, 0.5f, 1.0f };
			CGFloat colors[12] = { srgba.r, srgba.g, srgba.b, srgba.a,
									ergba.r, ergba.g, ergba.b, ergba.a,
									srgba.r, srgba.g, srgba.b, srgba.a };
			gradient = CGGradientCreateWithColorComponents(rgb, colors, points, count);
		}
		
		// Drawing gradient.
		CGPoint endPoint = CGPointMake(size.width, 0.0f);
		CGGradientDrawingOptions options = kCGGradientDrawsAfterEndLocation;
		CGContextDrawLinearGradient(context, gradient, CGPointZero, endPoint, options);
		
		// Gets the autoreleased image.
		image = UIGraphicsGetImageFromCurrentImageContext();
		
		// CG clean up.
		CGColorSpaceRelease(rgb);
		CGGradientRelease(gradient);
		UIGraphicsEndImageContext();
	}
	
	return image;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (BOOL) isEqual:(id)object
{
	BOOL result = NO;
	
	// Use class directly instead of "self", because it compare subclasses as well.
	if ([object isKindOfClass:[UIImage class]])
	{
		NSData *data1 = UIImagePNGRepresentation(self);
		NSData *data2 = UIImagePNGRepresentation(object);
		return ([data1 isEqual:data2]);
	}
	
	return result;
}

@end

#pragma mark -
#pragma mark Categories
#pragma mark -
//**********************************************************************************************************
//
//	Categories
//
//**********************************************************************************************************

@implementation NPP_IMAGE(NPPCipherImage)

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

- (NSString *) encodeJPEGWithBase64
{
	NSData *data = UIImageJPEGRepresentation(self, 0.9f);
	NSString *string = [NSString stringWithData:[data encodeBase64] encoding:NSUTF8StringEncoding];
	
	return [NPP_CIPHER_JPEG_64 stringByAppendingString:string];
}

- (NSString *) encodePNGWithBase64
{
	NSData *data = UIImagePNGRepresentation(self);
	NSString *string = [NSString stringWithData:[data encodeBase64] encoding:NSUTF8StringEncoding];
	
	return [NPP_CIPHER_PNG_64 stringByAppendingString:string];
}

+ (UIImage *) imageWithBase64:(NSString *)base64
{
	if ([base64 hasPrefix:NPP_CIPHER_JPEG_64])
	{
		base64 = [base64 substringFromIndex:[NPP_CIPHER_JPEG_64 length]];
	}
	else if ([base64 hasPrefix:NPP_CIPHER_PNG_64])
	{
		base64 = [base64 substringFromIndex:[NPP_CIPHER_PNG_64 length]];
	}
	
	NSData *data = [[base64 dataUsingEncoding:NSUTF8StringEncoding] decodeBase64];
	
	return [UIImage imageWithData:data];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end