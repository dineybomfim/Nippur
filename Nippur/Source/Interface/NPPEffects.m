/*
 *	NPPEffects.m
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

#import "NPPEffects.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_EFX_BLUR_NAME			@"NPPEfxBlur"
#define NPP_EFX_SHINE_NAME			@"NPPEfxShine"

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

static void nppDrawViewInRect(CGContextRef context, UIView *view)
{
	//*
	// Old iOS doesn't have the fastest way to render in context.
	if (nppDeviceOSVersion() < 7.0f || view.window == nil)
	{
		[view.layer renderInContext:context];
	}
	// Starting at iOS 7, there is a faster way to take snapshots.
	else
	{
		UIGraphicsPushContext(context);
		[view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
		UIGraphicsPopContext();
	}
	/*/
	[view.layer renderInContext:context];
	//*/
}

static NPPImage *nppSnapshot(UIView *view, CGRect rect, float scale)
{
	NPPImage *image = nil;
	CGContextRef context = NULL;
	
	scale = (scale > 0.0f) ? scale : [[UIScreen mainScreen] scale];
	image = [NPPImage imageWithSize:rect.size scale:scale];
	context = image.context;
	
	// Inverting the current context.
	CGContextTranslateCTM(context, 0.0f, rect.size.height * scale);
	CGContextScaleCTM(context, scale, -scale);
	CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
	
	// Drawing the view in context.
	nppDrawViewInRect(context, view);
	
	return image;
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

//NPP_STATIC_READONLY(nppGetBackdrops, NSMutableArray);

@interface NPPBackdropEffect : NSObject
{
@private
	BOOL					_isRunning;
	NSMutableArray			*_listeners;
}

@property (nonatomic, NPP_RETAIN) NPPImage *image;
@property (nonatomic, NPP_RETAIN) UIView *targetView;

- (void) addToLoop:(UIView *)listener;
- (void) removeFromLoop:(UIView *)listener;

@end

@implementation NPPBackdropEffect

@synthesize image = _image, targetView = _targetView;

- (void) addToLoop:(UIView *)listener
{
	if (_listeners == nil)
	{
		_listeners = [[NSMutableArray alloc] init];
	}
	
	if (!_isRunning)
	{
		_isRunning = YES;
		NPPThread *thread = nppThreadGet(NPP_EFX_BLUR_NAME);
		thread.type = NPPThreadTypeContinuous;
		[thread performAsync:@selector(imageLoop) target:self];
	}
	
	NSUInteger index = [_listeners indexOfObject:listener];
	
	if (index == NSNotFound)
	{
		[_listeners addObject:listener];
		
		NPPThread *threadTarget = nppThreadGet(@"Image");
		threadTarget.type = NPPThreadTypeContinuous;
		//[threadTarget performAsync:@selector(targetLoop) target:self];
	}
}

- (void) removeFromLoop:(UIView *)listener
{
	[_listeners removeObject:listener];
	
	if ([_listeners count] == 0)
	{
		_isRunning = NO;
		//remove from thread.
		NPPThread *thread = nppThreadGet(NPP_EFX_BLUR_NAME);
		[thread removeAllTasksForTarget:self];
	}
}

- (void) imageLoop
{
	dispatch_sync(dispatch_get_main_queue(), ^(void)
	{
		[_targetView.layer renderInContext:_image.context];
		
		UIView *topView = [_listeners objectAtIndex:0];
		UIView *blurredView = _targetView;
		
		// Calculating the coordinates.
		CGPoint origin = [topView convertPoint:CGPointZero toView:blurredView];
		CGRect rect = topView.frame;
		rect.origin = origin;
		
		//NPPImage *image = [_image NPPImage];
		//[image makeBoxBlur:4];
		
		topView.layer.contents = (__bridge id)[_image CGImage];
	});
}

- (void) targetLoop
{
	UIView *topView = [_listeners objectAtIndex:0];
	UIView *blurredView = _targetView;
	
	// Calculating the coordinates.
	CGPoint origin = [topView convertPoint:CGPointZero toView:blurredView];
	CGRect rect = topView.frame;
	rect.origin = origin;
	
	/*
	CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
	CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
	/*/
	NPPImage *image = [[_image imageCroppedInRect:rect] NPPImage];
	//*/
	
	[image makeBoxBlur:8];
	
	//*
	topView.layer.contents = (__bridge id)[_image CGImage];
	/*/
	// Getting the layer.
	CALayer *layer = self.efxLayer;
	[layer removeFromSuperlayer];
	
	layer.name = NPP_EFX_BLUR_NAME;
	layer.frame = (CGRect){ CGPointZero, rect.size };
	self.layer.contents = (NPP_ARC_BRIDGE id)[image CGImage];
	[topView.layer insertSublayer:layer atIndex:0];
	//*/
}

- (void) dealloc
{
	nppRelease(_listeners);
	nppRelease(_image);
	nppRelease(_targetView);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end




/*
static NPPBackdropEffect *nppGetEfx(UIView *top, UIView *target)
{
	NPPBackdropEffect *efx = nil;
	NSArray *array = [NSArray arrayWithArray:nppGetBackdrops()];
	BOOL hasEfx = NO;
	
	for (efx in array)
	{
		if ([efx.targetView isEqual:target])
		{
			hasEfx = YES;
			break;
		}
	}
	
	if (!hasEfx)
	{
		CGFloat scale = 0.5f;
		CGFloat blockSize = 12.0f / 4.0f;
		scale = blockSize / MAX(blockSize * 2, floor(40.0f));
		
		NPPImage *image = [[NPPImage alloc] initWithSize:target.size scale:scale];
		
		efx = nppAutorelease([[NPPBackdropEffect alloc] init]);
		efx.image = image;
		efx.targetView = target;
		
		nppRelease(image);
		
	}
	
	return efx;
}
//*/







static NSArray *nppHideViewsAbove(UIView *view)
{
	UIView *subview = nil;
	NSArray *subviews = [[view superview] subviews];
	NSMutableArray *views = [NSMutableArray array];
	NSUInteger index = [subviews indexOfObject:view];
	NSUInteger i = 0;
	NSUInteger count = [subviews count];
	
	if (index != NSNotFound)
	{
		for (i = index; i < count; ++i)
		{
			subview = [subviews objectAtIndex:i];
			
			if (!subview.hidden)
			{
				subview.hidden = YES;
				[views addObject:subview];
			}
		}
	}
	
	return views;
}

static void nppUnhiddenViews(NSArray *array)
{
	UIView *subview = nil;
	
	for (subview in array)
	{
		subview.hidden = NO;
	}
}



//TODO there is a lot to do here.
@interface NPPBackdropView() <NPPTimerItem>
{
	NPPImage				*_image;
	float					_scale;
	CGContextRef			_cgContext;
	CALayer					*_laBlur;
}

@property (nonatomic, assign, readonly) CGSize bufferSize;

// Initializes a new instance.
- (void) initializing;

- (void) recreateImageBuffers;

@end

@implementation NPPBackdropView

@synthesize autoUpdate = _autoUpdate, blurRadius = _blurRadius, blurredView = _blurredView;

- (float) blurRadius { return _blurRadius; }
- (void) setBlurRadius:(float)value
{
	_blurRadius = MAX(value, 0.1f);
	[self recreateImageBuffers];
}

- (id) init
{
	if (self = [super initWithFrame:CGRectZero])
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self initializing];
	}
	
	return self;
}

- (void) initializing
{
	_autoUpdate = YES;
	_blurRadius = 4.0f;
	self.opaque = NO;
	self.userInteractionEnabled = NO;
}

- (void) registerInLoop:(BOOL)value
{
	if (value)
	{
		[[NPPTimer instance] addItem:self];
	}
	else
	{
		[[NPPTimer instance] removeItem:self];
	}
}

- (void) updateBlur
{
	[self timerCallBack];
}

- (void) setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	[self recreateImageBuffers];
	[self timerCallBack];
}

- (void) setBounds:(CGRect)bounds
{
	[super setBounds:bounds];
	
	[self recreateImageBuffers];
	[self timerCallBack];
}

- (void) recreateImageBuffers
{
	CGRect bounds = self.bounds;
	CGFloat blockSize = 12.0f / _blurRadius;
	_scale = blockSize / MAX(blockSize * 2, floor(40.0f));
	
	nppRelease(_image);
	_image = [[NPPImage alloc] initWithSize:bounds.size scale:_scale];
	_cgContext = _image.context;
	
	nppRelease(_laBlur);
	_laBlur = [[CALayer alloc] init];
	_laBlur.name = NPP_EFX_BLUR_NAME;
	_laBlur.frame = bounds;
	
	[[self layer] addSublayer:_laBlur];
}

- (void) willMoveToSuperview:(UIView *)newSuperview
{
	[super willMoveToSuperview:newSuperview];
	
	// When adding to any view.
	if (newSuperview != nil)
	{
		[self recreateImageBuffers];
		[self timerCallBack];
		
		[self registerInLoop:YES];
	}
	// When removing from any superview.
	else
	{
		[self registerInLoop:NO];
	}
}

- (void) timerCallBack
{
	//*
	BOOL isSuperview = (_blurredView == nil);
	UIView *topView = self;
	UIView *blurredView = (isSuperview) ? self.superview : _blurredView;
	NSArray *hiddenViews = nil;
	
	if (blurredView == nil)
	{
		return;
	}
	
	// Calculating the coordinates.
	CGPoint origin = [topView convertPoint:CGPointZero toView:blurredView];
	CGRect rect = topView.frame;
	rect.origin = origin;
	
	if (isSuperview)
	{
		hiddenViews = nppHideViewsAbove(topView);
	}
	
	// Inverting the current context.
	CGContextSaveGState(_cgContext);
	CGContextTranslateCTM(_cgContext, 0.0f, rect.size.height * _scale);
	CGContextScaleCTM(_cgContext, _scale, -_scale);
	CGContextTranslateCTM(_cgContext, -rect.origin.x, -rect.origin.y);
	nppDrawViewInRect(_cgContext, blurredView);
	CGContextRestoreGState(_cgContext);
	
	if (isSuperview)
	{
		nppUnhiddenViews(hiddenViews);
	}
	
	[_image makeBoxBlur:1.0f];
	_laBlur.contents = (__bridge id)([_image CGImage]);
	
	// Stop updating for non-auto-updating views.
	if (!_autoUpdate)
	{
		[self registerInLoop:NO];
	}
	//*/
}

- (void) dealloc
{
	// Impossible to be in a loop at this point, so doesn't need to remove from loop.
	
	nppRelease(_image);
	nppRelease(_laBlur);
	nppRelease(_blurredView);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end

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
#pragma mark UIView Category
#pragma mark -
//**********************************************************************************************************
//
//	UIView Categories
//
//**********************************************************************************************************

@implementation UIView (NPPEffects)

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

//NPP_CATEGORY_PROPERTY_READONLY(OBJC_ASSOCIATION_RETAIN_NONATOMIC, CALayer *, efxLayer);

#pragma mark -
#pragma mark Self Private Methods
//**************************************************
//	Self Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (NPPImage *) snapshot
{
	return nppSnapshot(self, self.bounds, 0.0f);
}

- (NPPImage *) snapshotInRect:(CGRect)rect
{
	return nppSnapshot(self, rect, 0.0f);
}

- (void) efxAddShineTo:(NPPDirection)direction color:(UIColor *)color duration:(float)seconds
{
	// Make sure only one shine effect will be attached.
	[self efxRemoveShine];
	
	// Creating the necessary sources.
	CGRect maskFrame = CGRectZero;
	UIImage *maskImage = nil;
	CGRect fullFrame = self.bounds;
	UIImage *whiteSnapshot = nppSnapshot(self, fullFrame, 0.0f);
	NSString *moveKey = nil;
	float toValue = 0.0f;
	
	// Adjusting the directions.
	switch (direction)
	{
		case NPPDirectionUp:
			maskFrame.size.width = fullFrame.size.width;
			maskFrame.size.height = fullFrame.size.height * 0.25f;
			maskFrame.origin = CGPointMake(0.0f, fullFrame.size.height);
			moveKey = @"position.y";
			toValue = -maskFrame.size.height;
			break;
		case NPPDirectionDown:
			maskFrame.size.width = fullFrame.size.width;
			maskFrame.size.height = fullFrame.size.height * 0.25f;
			maskFrame.origin = CGPointMake(0.0f, -maskFrame.size.height);
			moveKey = @"position.y";
			toValue = fullFrame.size.height;
			break;
		case NPPDirectionLeft:
			maskFrame.size.width = fullFrame.size.width * 0.25f;
			maskFrame.size.height = fullFrame.size.height;
			maskFrame.origin = CGPointMake(fullFrame.size.width, 0.0f);
			moveKey = @"position.x";
			toValue = -maskFrame.size.width;
			break;
		case NPPDirectionRight:
		default:
			maskFrame.size.width = fullFrame.size.width * 0.25f;
			maskFrame.size.height = fullFrame.size.height;
			maskFrame.origin = CGPointMake(-maskFrame.size.width, 0.0f);
			moveKey = @"position.x";
			toValue = fullFrame.size.width;
			break;
	}
	
	UIColor *startColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
	UIColor *endColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
	
	fullFrame.origin = CGPointZero;
	maskImage = [UIImage imageWithLinearGradient:maskFrame.size start:startColor end:endColor mirror:YES];
	
	// Creates the shining layer.
	CALayer *whiteLayer = [CALayer layer];
	whiteLayer.name = NPP_EFX_SHINE_NAME;
	whiteLayer.contents = (id)[[whiteSnapshot imageTinted:color] CGImage];
	whiteLayer.frame = fullFrame;
	[[self layer] addSublayer:whiteLayer];
	
	// Creates the shining mask layer.
	CALayer *maskLayer = [CALayer layer];
	maskLayer.contents = (id)[maskImage CGImage];
	maskLayer.frame = maskFrame;
	whiteLayer.mask = maskLayer;
	
	// Making the CA animation from left to right of the defined view.
	CABasicAnimation *maskAnim = [CABasicAnimation animationWithKeyPath:moveKey];
	maskAnim.toValue = [NSNumber numberWithFloat:toValue];
	maskAnim.repeatCount = NPP_MAX_32F;
	maskAnim.duration = seconds;
	[maskLayer addAnimation:maskAnim forKey:NPP_EFX_SHINE_NAME];
}

- (void) efxRemoveShine
{
	CALayer *layer = nil;
	NSArray *sublayers = [NSArray arrayWithArray:[[self layer] sublayers]];
	
	// Removing all shine effect layer.
	for (layer in sublayers)
	{
		if ([[layer name] isEqualToString:NPP_EFX_SHINE_NAME])
		{
			[[layer mask] removeAllAnimations];
			[layer removeFromSuperlayer];
		}
	}
}

@end