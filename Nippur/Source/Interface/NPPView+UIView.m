/*
 *	NPPView+UIView.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 9/27/11.
 *	Copyright 2011 db-in. All rights reserved.
 */

#import "NPPView+UIView.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

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

// Scroll
NPP_ARC_RETAIN static NSString *_defaultScrollHorizontal = nil;
NPP_ARC_RETAIN static NSString *_defaultScrollVertical = nil;

// Page Control
NPP_ARC_RETAIN static NSString *_defaultPageControlNormal = nil;
NPP_ARC_RETAIN static NSString *_defaultPageControlSelected = nil;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
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
#pragma mark Public Function
//**************************************************
//	Public Function
//**************************************************

void nppClockMaskLayer(UIView *view, float percentage, NPPDirection starting)
{
	float angle = 0.0f;
	
	switch (starting)
	{
		case NPPDirectionUp:
			angle = -90.0f;
			break;
		case NPPDirectionRight:
			angle = 0.0f;
			break;
		case NPPDirectionDown:
			angle = 90.0f;
			break;
		case NPPDirectionLeft:
		default:
			angle = 180.0f;
			break;
	}
	
	// Animating the arc.
	CGRect bounds = [view bounds];
	CGPoint center = CGPointMake(bounds.size.width * 0.5f, bounds.size.height * 0.5f);
	CGFloat startAngle = NPPDegreesToRadians(angle);
	CGFloat endAngle = NPPDegreesToRadians(angle + (360.0f * percentage));
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path addArcWithCenter:center radius:center.x startAngle:startAngle endAngle:endAngle clockwise:YES];
	[path addArcWithCenter:center radius:0.0f startAngle:endAngle endAngle:startAngle clockwise:NO];
	[path closePath];
	
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = [path CGPath];
	shapeLayer.frame = bounds;
	shapeLayer.fillColor = [[UIColor redColor] CGColor];
	view.layer.mask = shapeLayer;
}

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

@implementation UIView (NPPView)

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

+ (id) view
{
	UIView *aView = [[self alloc] init];
	
	return nppAutorelease(aView);
}

+ (id) viewWithFrame:(CGRect)frame
{
	UIView *aView = [[self alloc] initWithFrame:frame];
	
	return nppAutorelease(aView);
}

+ (id) viewWithFrame:(CGRect)frame andBackgroundColor:(UIColor *)color
{
	UIView *aView = [[self alloc] initWithFrame:frame];
	aView.backgroundColor = color;
	
	return nppAutorelease(aView);
}

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

//*************************
//	Basics 2D
//*************************

- (float) x { return self.frame.origin.x; }
- (void) setX:(float)value
{
	CGRect frame = self.frame;
	frame.origin.x = value;
	self.frame = frame;
}

- (float) y { return self.frame.origin.y; }
- (void) setY:(float)value
{
	CGRect frame = self.frame;
	frame.origin.y = value;
	self.frame = frame;
}

- (float) width { return self.frame.size.width; }
- (void) setWidth:(float)value
{
	CGRect frame = self.frame;
	frame.size.width = value;
	self.frame = frame;
}

- (float) height { return self.frame.size.height; }
- (void) setHeight:(float)value
{
	CGRect frame = self.frame;
	frame.size.height = value;
	self.frame = frame;
}

- (CGPoint) origin { return self.frame.origin; }
- (void) setOrigin:(CGPoint)value
{
	CGRect frame = self.frame;
	frame.origin = value;
	self.frame = frame;
}

- (CGSize) size { return self.frame.size; }
- (void) setSize:(CGSize)value
{
	CGRect frame = self.frame;
	frame.size = value;
	self.frame = frame;
}

- (float) boundsX { return self.bounds.origin.x; }
- (void) setBoundsX:(float)value
{
	CGRect bounds = self.bounds;
	bounds.origin.x = value;
	self.bounds = bounds;
}

- (float) boundsY { return self.bounds.origin.y; }
- (void) setBoundsY:(float)value
{
	CGRect bounds = self.bounds;
	bounds.origin.y = value;
	self.bounds = bounds;
}

- (float) boundsWidth { return self.bounds.size.width; }
- (void) setBoundsWidth:(float)value
{
	CGRect bounds = self.bounds;
	bounds.size.width = value;
	self.bounds = bounds;
}

- (float) boundsHeight { return self.bounds.size.height; }
- (void) setBoundsHeight:(float)value
{
	CGRect bounds = self.bounds;
	bounds.size.height = value;
	self.bounds = bounds;
}

- (float) rotation { CGAffineTransform t = self.transform; return NPPRadiansToDegrees(atan2f(t.b, t.a)); }
- (void) setRotation:(float)value
{
	float angle = NPPDegreesToRadians(value);
	CGAffineTransform transform = self.transform;
	transform.a = cosf(angle);
	transform.b = sinf(angle);
	transform.c = -transform.b;
	transform.d = transform.a;
	self.transform = transform;
}

- (float) scale {  CGAffineTransform t = self.transform; return t.a; }
- (void) setScale:(float)value
{
	CGAffineTransform scale = self.transform;
	scale.a = value;
	scale.b = 0.0f;
	scale.c = 0.0f;
	scale.d = value;
	self.transform = scale;
}

- (float) translateX2D { return self.transform.tx; }
- (void) setTranslateX2D:(float)value
{
	CGAffineTransform translate = self.transform;
	translate.tx = value;
	self.transform = translate;
}

- (float) translateY2D { return self.transform.ty; }
- (void) setTranslateY2D:(float)value
{
	CGAffineTransform translate = self.transform;
	translate.ty = value;
	self.transform = translate;
}

//*************************
//	Basics 3D
//*************************

- (void) setTranslateX:(float)x y:(float)y z:(float)z
{
	CATransform3D transform = self.layer.transform;
	transform.m41 = x;
	transform.m42 = y;
	transform.m43 = z;
	self.layer.transform = transform;
}

- (float) translateX { return self.layer.transform.m41; }
- (void) setTranslateX:(float)value
{
	CATransform3D transform = self.layer.transform;
	transform.m41 = value;
	self.layer.transform = transform;
}

- (float) translateY { return self.layer.transform.m42; }
- (void) setTranslateY:(float)value
{
	CATransform3D transform = self.layer.transform;
	transform.m42 = value;
	self.layer.transform = transform;
}

- (float) translateZ { return self.layer.transform.m43; }
- (void) setTranslateZ:(float)value
{
	CATransform3D transform = self.layer.transform;
	transform.m43 = value;
	self.layer.transform = transform;
}

- (void) setScaleX:(float)x y:(float)y z:(float)z
{
	CATransform3D transform = CATransform3DMakeScale(x, y, z);
	self.layer.transform = transform;
}

- (float) scaleX { return [[self.layer valueForKeyPath:@"transform.scale.x"] floatValue]; }
- (void) setScaleX:(float)value
{
	[self.layer setValue:[NSNumber numberWithFloat:value]
			  forKeyPath:@"transform.scale.x"];
}

- (float) scaleY { return [[self.layer valueForKeyPath:@"transform.scale.y"] floatValue]; }
- (void) setScaleY:(float)value
{
	[self.layer setValue:[NSNumber numberWithFloat:value]
			  forKeyPath:@"transform.scale.y"];
}

- (float) scaleZ { return [[self.layer valueForKeyPath:@"transform.scale.z"] floatValue]; }
- (void) setScaleZ:(float)value
{
	[self.layer setValue:[NSNumber numberWithFloat:value]
			  forKeyPath:@"transform.scale.z"];
}

- (void) setRotate:(float)radians x:(float)x y:(float)y z:(float)z
{
	CATransform3D transform = CATransform3DMakeRotation(radians, x, y, z);
	self.layer.transform = transform;
}

- (float) rotateX
{
	return NPPRadiansToDegrees([[self.layer valueForKeyPath:@"transform.rotation.x"] floatValue]);
}
- (void) setRotateX:(float)value
{
	[self.layer setValue:[NSNumber numberWithFloat:NPPDegreesToRadians(value)]
			  forKeyPath:@"transform.rotation.x"];
}

- (float) rotateY
{
	return NPPRadiansToDegrees([[self.layer valueForKeyPath:@"transform.rotation.y"] floatValue]);
}
- (void) setRotateY:(float)value
{
	[self.layer setValue:[NSNumber numberWithFloat:NPPDegreesToRadians(value)]
			  forKeyPath:@"transform.rotation.y"];
}

- (float) rotateZ
{
	return NPPRadiansToDegrees([[self.layer valueForKeyPath:@"transform.rotation.z"] floatValue]);
}
- (void) setRotateZ:(float)value
{
	[self.layer setValue:[NSNumber numberWithFloat:NPPDegreesToRadians(value)]
			  forKeyPath:@"transform.rotation.z"];
}

//*************************
//	Alignment
//*************************

- (float) centerX { return self.center.x; }
- (void) setCenterX:(float)value
{
	CGPoint center = self.center;
	center.x = value;
	self.center = center;
}

- (float) centerY { return self.center.y; }
- (void) setCenterY:(float)value
{
	CGPoint center = self.center;
	center.y = value;
	self.center = center;
}

- (void) centerXInView:(UIView *)view
{
	CGRect viewFrame = view.bounds;
	CGRect frame = self.frame;
	
	frame.origin.x = (viewFrame.size.width * 0.5f) - (frame.size.width * 0.5f);
	self.frame = frame;
}

- (void) centerYInView:(UIView *)view
{
	CGRect viewFrame = view.bounds;
	CGRect frame = self.frame;
	
	frame.origin.y = (viewFrame.size.height * 0.5f) - (frame.size.height * 0.5f);
	self.frame = frame;
}

- (void) centerInView:(UIView *)view
{
	[self centerInRect:view.bounds];
}

- (void) centerInRect:(CGRect)rect
{
	CGRect frame = self.frame;
	
	frame.origin.x = (rect.size.width * 0.5f) - (frame.size.width * 0.5f);
	frame.origin.y = (rect.size.height * 0.5f) - (frame.size.height * 0.5f);
	self.frame = frame;
}

//*************************
//	Effects
//*************************

- (float) shadowX { return self.layer.shadowOffset.width; }
- (void) setShadowX:(float)value
{
	CALayer *layer = self.layer;
	
	if (layer.masksToBounds)
	{
		layer.shadowRadius = (layer.shadowRadius != 0.0f) ? layer.shadowRadius : 10.0f;
	}
	
	layer.shadowOffset = CGSizeMake(value, layer.shadowOffset.height);
}

- (float) shadowY { return self.layer.shadowOffset.height; }
- (void) setShadowY:(float)value
{
	CALayer *layer = self.layer;
	
	if (layer.masksToBounds)
	{
		layer.shadowRadius = (layer.shadowRadius != 0.0f) ? layer.shadowRadius : 10.0f;
	}
	
	layer.shadowOffset = CGSizeMake(layer.shadowOffset.width, value);
}

- (float) shadowAlpha { return self.layer.shadowOpacity; }
- (void) setShadowAlpha:(float)value
{
	self.layer.shadowOpacity = value;
}

- (void) shadowAt:(NPPPosition)position offset:(float)offset
{
	CALayer *layer = self.layer;
	CGSize size = self.frame.size;
	CGRect rect;
	
	switch (position)
	{
		case NPPPositionRight:
			rect = CGRectMake(size.width, 0.0f, offset, size.height);
			break;
		case NPPPositionBottom:
			rect = CGRectMake(0.0f, size.height, size.width, offset);
			break;
		case NPPPositionLeft:
			rect = CGRectMake(0.0f, 0.0f, -offset, size.height);
			break;
		case NPPPositionTop:
		default:
			rect = CGRectMake(0.0f, 0.0f, size.width, -offset);
			break;
	}
	
	layer.shadowPath = [[UIBezierPath bezierPathWithRect:rect] CGPath];
	layer.shadowOpacity = 0.75f;
	layer.shadowRadius = 7.0f;
	layer.shadowColor = [[UIColor blackColor] CGColor];
}

- (void) fadeAlphaAt:(NPPPosition)position startAt:(float)start endAt:(float)end mirror:(BOOL)mirror
{
	// Aboiding the zero size layer.
	CGRect bounds = self.bounds;
	if (bounds.size.width == 0 || bounds.size.height == 0)
	{
		return;
	}
	
	// Creating and preparing the new layer.
	id clear = (id)[UIColor clearColor].CGColor;
	id color = (id)[UIColor blackColor].CGColor;
	CAGradientLayer *layer = [CAGradientLayer layer];
	layer.shouldRasterize = YES;
	layer.rasterizationScale = [[UIScreen mainScreen] scale];
	layer.frame = bounds;
	
	
	if (!mirror)
	{
		layer.colors = [NSArray arrayWithObjects:clear, color, nil];
	}
	else
	{
		layer.colors = [NSArray arrayWithObjects:clear, color, color, clear, nil];
	}
	
	//TODO layer does not autoresizingmask
//	- (void)layoutSubviews {
//		// resize your layers based on the view's new bounds
//		mylayer.frame = self.bounds;
//	}
	
	// Constructing the fading area.
	/*
	switch (position)
	{
		case NPPPositionRight:
			start /= bounds.size.width;
			end /= bounds.size.width;
			layer.startPoint = CGPointMake(1.0f - start, 1.0f);
			layer.endPoint = CGPointMake(1.0f - end, 1.0f);
			break;
		case NPPPositionBottom:
			start /= bounds.size.height;
			end /= bounds.size.height;
			layer.startPoint = CGPointMake(1.0f, 1.0f - start);
			layer.endPoint = CGPointMake(1.0f, 1.0f - end);
			break;
		case NPPPositionLeft:
			start /= bounds.size.width;
			end /= bounds.size.width;
			layer.startPoint = CGPointMake(start, 1.0f);
			layer.endPoint = CGPointMake(end, 1.0f);
			break;
		case NPPPositionTop:
		default:
			start /= bounds.size.height;
			end /= bounds.size.height;
			layer.startPoint = CGPointMake(1.0f, start);
			layer.endPoint = CGPointMake(1.0f, end);
			break;
	}
	/*/
	switch (position)
	{
		case NPPPositionRight:
			start /= bounds.size.width;
			end /= bounds.size.width;
			layer.startPoint = CGPointMake(1.0f, 1.0f);
			layer.endPoint = CGPointMake(0.0f, 1.0f);
			break;
		case NPPPositionBottom:
			start /= bounds.size.height;
			end /= bounds.size.height;
			layer.startPoint = CGPointMake(1.0f, 1.0f);
			layer.endPoint = CGPointMake(1.0f, 0.0f);
			break;
		case NPPPositionLeft:
			start /= bounds.size.width;
			end /= bounds.size.width;
			layer.startPoint = CGPointMake(0.0f, 1.0f);
			layer.endPoint = CGPointMake(1.0f, 1.0f);
			break;
		case NPPPositionTop:
		default:
			start /= bounds.size.height;
			end /= bounds.size.height;
			layer.startPoint = CGPointMake(1.0f, 0.0f);
			layer.endPoint = CGPointMake(1.0f, 1.0f);
			break;
	}
	
	layer.locations = @[[NSNumber numberWithFloat:start], [NSNumber numberWithFloat:end],
						[NSNumber numberWithFloat:1.0f - end], [NSNumber numberWithFloat:1.0f - start]];
	//*/
//	layer.position = CGPointMake(bounds.size.width * 0.5f, bounds.size.height * 0.5f);
//	layer.startPoint = CGPointMake(0, 1.0f);
//	layer.endPoint = CGPointMake(1, 1.0f);
//	layer.locations = @[@0, @0.2, @0.8, @1];

	
	if (start == 0.0f && end == 0.0f)
	{
		layer = nil;
	}
	
	self.layer.mask = layer;
}

+ (void) screenFlash
{
	// Flash the screen white and fade it out to give UI feedback that a still image was taken
	UIWindow *lastWindow = [[[UIApplication sharedApplication] windows] lastObject];
	__block UIView *flashView = [[UIView alloc] initWithFrame:lastWindow.bounds];
	[flashView setBackgroundColor:[UIColor whiteColor]];
	[lastWindow addSubview:flashView];
	
	[UIView animateWithDuration:.4f
					 animations:^{
						 [flashView setAlpha:0.f];
					 }
					 completion:^(BOOL finished){
						 [flashView removeFromSuperview];
						 nppRelease(flashView);
					 }
	 ];
}

//*************************
//	Animations
//*************************

- (void) moveProperty:(NSString *)property to:(float)to completion:(NPPBlockVoid)block
{
	//*
	// Animation.
	NPPBlockVoid anim = ^(void)
	{
		[self setValue:[NSNumber numberWithFloat:to] forKeyPath:property];
	};
	
	[UIView moveSetTo:anim completion:block];
	/*/
	[self runAction:[NPPAction moveKey:property to:to duration:kNPPAnimTime] completion:block];
	//*/
}

- (void) moveProperty:(NSString *)property from:(float)from completion:(NPPBlockVoid)block
{
	//*
	float to = [[self valueForKeyPath:property] floatValue];
	[self setValue:[NSNumber numberWithFloat:from] forKeyPath:property];
	
	double delayInSeconds = 0.01f;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
	{
		[self moveProperty:property to:to completion:nil];
	});
	/*/
	[self runAction:[NPPAction moveKey:property from:from duration:kNPPAnimTime] completion:block];
	//*/
}

- (void) moveProperty:(NSString *)property from:(float)from to:(float)to completion:(NPPBlockVoid)block
{
	//*
	[self setValue:[NSNumber numberWithFloat:from] forKeyPath:property];
	
	double delayInSeconds = 0.01f;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
	{
		[self moveProperty:property to:to completion:nil];
	});
	/*/
	[self runAction:[NPPAction moveKey:property from:from to:to duration:kNPPAnimTime] completion:block];
	//*/
}

+ (void) moveSetTo:(NPPBlockVoid)to completion:(NPPBlockVoid)block
{
	// Settings.
	int options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear;
	void (^end)(BOOL) = ^(BOOL finished)
	{
		nppBlock(block);
	};
	
	[UIView animateWithDuration:kNPPAnimTime delay:0.0f options:options animations:to completion:end];
}

+ (void) moveSetFrom:(NPPBlockVoid)from completion:(NPPBlockVoid)block
{
	//TODO find a good way to move set from-to.
}

+ (void) moveSetFrom:(NPPBlockVoid)from to:(NPPBlockVoid)to completion:(NPPBlockVoid)block
{
	nppBlock(from);
	
	// Settings.
	int options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear;
	void (^end)(BOOL) = ^(BOOL finished)
	{
		nppBlock(block);
	};
	
	[UIView animateWithDuration:kNPPAnimTime delay:0.0f options:options animations:to completion:end];
}

- (void) moveProperty:(NSString *)property fromValue:(float)fromValue toValue:(float)toValue
{
	//TODO find a way.
}

- (void) executeAfterAnimation:(NPPBlockVoid)block
{
	if (block != nil)
	{
		double delayInSeconds = kNPPAnimTime;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), block);
	}
}

//*************************
//	View Manipulation
//*************************

- (void) toggleHidden
{
	self.hidden = !self.hidden;
}

- (void) removeSubviewWithTag:(unsigned int)tag
{
	UIView *subview;
	NSArray *subviews = [self subviews];
	
	for (subview in subviews)
	{
		if (subview.tag == tag)
		{
			[subview removeFromSuperview];
			break;
		}
	}
}

- (void) removeSubviewAtIndex:(NSUInteger)index
{
	NSArray *subviews = [self subviews];
	
	if (index < [subviews count])
	{
		[[subviews objectAtIndex:index] removeFromSuperview];
	}
}

- (void) removeAllSubviews
{
	UIView *subview;
	NSArray *subviews = [self subviews];
	
	for (subview in subviews)
	{
		[subview removeFromSuperview];
	}
}

- (void) removeAllSubviewsWithTag:(unsigned int)tag
{
	UIView *subview;
	NSArray *subviews = [self subviews];
	
	for (subview in subviews)
	{
		if (subview.tag == tag)
		{
			[subview removeFromSuperview];
		}
	}
}

- (void) removeFromSuperviewAfterAnimation
{
	__block id bself = self;
	
	[self executeAfterAnimation:^(void)
	{
		[bself removeFromSuperview];
	}];
}

- (void) removeAllGestures
{
	UIGestureRecognizer *recognizer = nil;
	NSArray *gestures = self.gestureRecognizers;
	
	for (recognizer in gestures)
	{
		[self removeGestureRecognizer:recognizer];
	}
}

//*************************
//	Controllers
//*************************

- (UIView *) subviewWithTag:(NSInteger)tag
{
	UIView *subview = nil;
	NSArray *subviews = [self subviews];
	
	for (subview in subviews)
	{
		if (subview.tag == tag)
		{
			return subview;
		}
	}
	
	return nil;
}

- (UIView *) findFirstResponder
{
	UIView *subview = nil;
	UIView *firstView = nil;
	NSArray *subviews = [self subviews];
	
	if ([self isFirstResponder])
	{
		return self;
	}
	
	for (subview in subviews)
	{
		firstView = [subview findFirstResponder];
		if (nil != firstView)
		{
			return firstView;
		}
	}
	
	return nil;
}

+ (UIView *) findFirstResponder
{
	NSArray *windows = [[UIApplication sharedApplication] windows];
	UIWindow *window = nil;
	UIView *view = nil;
	
	for (window in windows)
	{
		view = [window findFirstResponder];
		if (view != nil)
		{
			break;
		}
	}
	
	return view;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end

#pragma mark -
#pragma mark UIScrollView Category
#pragma mark -
//**********************************************************************************************************
//
//	UIScrollView Categories
//
//**********************************************************************************************************

@implementation UIScrollView (NPPScrollView)

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

- (void) nppSwBringSubviewToFront:(UIView *)view
{
	[self nppSwBringSubviewToFront:view];
	
	UIImage *image = nil;
	UIImageView *ivScroll = ([view isKindOfClass:[UIImageView class]]) ? (UIImageView *)view : nil;
	
	if (ivScroll.autoresizingMask == UIViewAutoresizingFlexibleLeftMargin)
	{
		if (_defaultScrollVertical != nil)
		{
			image = nppImageFromFile(_defaultScrollVertical);
			ivScroll.image = [image imageNineSliced];
			ivScroll.contentMode = UIViewContentModeScaleToFill;
			ivScroll.width = image.size.width;
		}
	}
	else if (ivScroll.autoresizingMask == UIViewAutoresizingFlexibleTopMargin)
	{
		if (_defaultScrollHorizontal != nil)
		{
			image = nppImageFromFile(_defaultScrollHorizontal);
			ivScroll.image = [image imageNineSliced];
			ivScroll.contentMode = UIViewContentModeScaleToFill;
			ivScroll.height = image.size.height;
		}
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

//*************************
//	Basic Movements
//*************************

- (float) contentOffsetX { return self.contentOffset.x; }
- (void) setContentOffsetX:(float)offsetX
{
	CGPoint point = self.contentOffset;
	point.x = offsetX;
	self.contentOffset = point;
}

- (float) contentOffsetY { return self.contentOffset.y; }
- (void) setContentOffsetY:(float)offsetY
{
	CGPoint point = self.contentOffset;
	point.y = offsetY;
	self.contentOffset = point;
}

- (float) contentWidth { return self.contentSize.width; }
- (void) setContentWidth:(float)width
{
	CGSize size = self.contentSize;
	size.width = width;
	self.contentSize = size;
}

- (float) contentHeight { return self.contentSize.height; }
- (void) setContentHeight:(float)height
{
	CGSize size = self.contentSize;
	size.height = height;
	self.contentSize = size;
}

- (void) setContentOffsetX:(float)offsetX animated:(BOOL)animated
{
	CGPoint point = self.contentOffset;
	point.x = offsetX;
	[self setContentOffset:point animated:animated];
}

- (void) setContentOffsetY:(float)offsetY animated:(BOOL)animated
{
	CGPoint point = self.contentOffset;
	point.y = offsetY;
	[self setContentOffset:point animated:animated];
}

//*************************
//	Customization
//*************************

+ (void) defineScrollbarHorizontal:(NSString *)horizontal vertical:(NSString *)vertical
{
	nppRelease(_defaultScrollHorizontal);
	nppRelease(_defaultScrollVertical);
	
	_defaultScrollHorizontal = nppRetain(horizontal);
	_defaultScrollVertical = nppRetain(vertical);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

+ (void) load
{
	Class aClass = [self class];
	SEL oldAddSel, newAddSel;
	
	oldAddSel = @selector(bringSubviewToFront:);
	newAddSel = @selector(nppSwBringSubviewToFront:);
	
	nppSwizzle(aClass, oldAddSel, newAddSel);
}

@end

#pragma mark -
#pragma mark CALayer Category
#pragma mark -
//**********************************************************************************************************
//
//	CALayer Categories
//
//**********************************************************************************************************

@implementation CALayer (NPPLayer)

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

//*************************
//	Basics
//*************************

- (CGPoint) pivot { return self.anchorPoint; }
- (void) setPivot:(CGPoint)value
{
	CGRect bounds = [self bounds];
	self.anchorPoint = value;
	self.position = (CGPoint){ bounds.size.width * value.x, bounds.size.height * value.y };
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end

#pragma mark -
#pragma mark UIPageControl Category
#pragma mark -
//**********************************************************************************************************
//
//	UIPageControl Categories
//
//**********************************************************************************************************

@implementation UIPageControl(NPPPageControl)

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

- (void) makeLayout
{
	CALayer *layer = nil;
	UIView *view = nil;
	NSArray *subviews = self.subviews;
	UIImage *dotImage = nil;
	
	for (view in subviews)
	{
		// Just change when a valid asset is defined.
		if (_defaultPageControlNormal != nil)
		{
			dotImage = nppImageFromFile(_defaultPageControlNormal);
			view.backgroundColor = nil;
			layer = view.layer;
			[layer setCornerRadius:0];
			[layer setContents:(id)[dotImage CGImage]];
			view.size = dotImage.size;
		}
	}
}

- (void) nppSwSetCurrentPage:(NSInteger)currentPage
{
	[self nppSwSetCurrentPage:currentPage];
	
	// Unselected.
	[self makeLayout];
	
	// Selected.
	CALayer *layer = nil;
	UIView *view = nil;
	NSArray *subviews = self.subviews;
	
	// Just change when a valid asset is defined.
	if (currentPage < [subviews count] && _defaultPageControlSelected != nil)
	{
		view = [subviews objectAtIndex:currentPage];
		view.backgroundColor = nil;
		layer = view.layer;
		[layer setContents:(id)[nppImageFromFile(_defaultPageControlSelected) CGImage]];
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

//*************************
//	Customization
//*************************

+ (void) defineLayout:(NSString *)normal selected:(NSString *)selected
{
	nppRelease(_defaultPageControlNormal);
	nppRelease(_defaultPageControlSelected);
	
	_defaultPageControlNormal = nppRetain(normal);
	_defaultPageControlSelected = nppRetain(selected);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

+ (void) load
{
	Class aClass = [self class];
	SEL oldAddSel, newAddSel;
	
	oldAddSel = @selector(setCurrentPage:);
	newAddSel = @selector(nppSwSetCurrentPage:);
	
	nppSwizzle(aClass, oldAddSel, newAddSel);
}

@end