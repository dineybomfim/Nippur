/*
 *	NPPView+UIView.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 9/27/11.
 *	Copyright 2011 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPImage+UIImage.h"

//TODO
#if NPP_IOS
	#define NPP_VIEW				UIView
#else
	#define NPP_VIEW				NSView
#endif

typedef enum
{
	NPPAutoresizingTopLeft		= UIViewAutoresizingFlexibleBottomMargin |
								  UIViewAutoresizingFlexibleRightMargin,
	NPPAutoresizingTopRight		= UIViewAutoresizingFlexibleBottomMargin |
								  UIViewAutoresizingFlexibleLeftMargin,
	NPPAutoresizingBottomLeft	= UIViewAutoresizingFlexibleTopMargin |
								  UIViewAutoresizingFlexibleRightMargin,
	NPPAutoresizingBottomRight	= UIViewAutoresizingFlexibleTopMargin |
								  UIViewAutoresizingFlexibleLeftMargin,
	NPPAutoresizingHorizontal	= UIViewAutoresizingFlexibleLeftMargin |
								  UIViewAutoresizingFlexibleRightMargin,
	NPPAutoresizingVertical		= UIViewAutoresizingFlexibleTopMargin |
								  UIViewAutoresizingFlexibleBottomMargin,
	NPPAutoresizingSizes		= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight,
	NPPAutoresizingAllMargins	= NPPAutoresizingHorizontal | NPPAutoresizingVertical,
	NPPAutoresizingAll			= NPPAutoresizingAllMargins | NPPAutoresizingSizes,
} NPPAutoresizing;

NPP_API void nppClockMaskLayer(UIView *view, float percentage, NPPDirection starting);

#pragma mark -
#pragma mark UIView Category
//**************************************************
//	UIView Category
//**************************************************

@interface UIView(NPPView)

//*************************
//	Constructors
//*************************

+ (id) view;
+ (id) viewWithFrame:(CGRect)frame;
+ (id) viewWithFrame:(CGRect)frame andBackgroundColor:(UIColor *)color;

//*************************
//	Basics 2D
//*************************

- (float) x;
- (void) setX:(float)value;

- (float) y;
- (void) setY:(float)value;

- (float) width;
- (void) setWidth:(float)value;

- (float) height;
- (void) setHeight:(float)value;

- (CGPoint) origin;
- (void) setOrigin:(CGPoint)value;

- (CGSize) size;
- (void) setSize:(CGSize)value;

- (float) boundsX;
- (void) setBoundsX:(float)value;

- (float) boundsY;
- (void) setBoundsY:(float)value;

- (float) boundsWidth;
- (void) setBoundsWidth:(float)value;

- (float) boundsHeight;
- (void) setBoundsHeight:(float)value;

- (float) rotation;
- (void) setRotation:(float)value;

- (float) scale;
- (void) setScale:(float)value;

- (float) translateX2D;
- (void) setTranslateX2D:(float)value;

- (float) translateY2D;
- (void) setTranslateY2D:(float)value;

//*************************
//	Basics 3D
//*************************

- (void) setTranslateX:(float)x y:(float)y z:(float)z;

- (float) translateX;
- (void) setTranslateX:(float)value;

- (float) translateY;
- (void) setTranslateY:(float)value;

- (float) translateZ;
- (void) setTranslateZ:(float)value;

- (void) setScaleX:(float)x y:(float)y z:(float)z;

- (float) scaleX;
- (void) setScaleX:(float)value;

- (float) scaleY;
- (void) setScaleY:(float)value;

- (float) scaleZ;
- (void) setScaleZ:(float)value;

- (void) setRotate:(float)radians x:(float)x y:(float)y z:(float)z;

- (float) rotateX;
- (void) setRotateX:(float)value;

- (float) rotateY;
- (void) setRotateY:(float)value;

- (float) rotateZ;
- (void) setRotateZ:(float)value;

//*************************
//	Alignment
//*************************

- (float) centerX;
- (void) setCenterX:(float)value;

- (float) centerY;
- (void) setCenterY:(float)value;

- (void) centerXInView:(UIView *)view;
- (void) centerYInView:(UIView *)view;
- (void) centerInView:(UIView *)view;
- (void) centerInRect:(CGRect)rect;

//*************************
//	Effects
//*************************

- (float) shadowX;
- (void) setShadowX:(float)value;

- (float) shadowY;
- (void) setShadowY:(float)value;

- (float) shadowAlpha;
- (void) setShadowAlpha:(float)value;

- (void) shadowAt:(NPPPosition)position offset:(float)offset;

- (void) fadeAlphaAt:(NPPPosition)position startAt:(float)start endAt:(float)end mirror:(BOOL)mirror;

+ (void) screenFlash;

//*************************
//	Animations
//*************************

- (void) moveProperty:(NSString *)property to:(float)to completion:(NPPBlockVoid)block;
- (void) moveProperty:(NSString *)property from:(float)from completion:(NPPBlockVoid)block;
- (void) moveProperty:(NSString *)property from:(float)from to:(float)to completion:(NPPBlockVoid)block;

+ (void) moveSetTo:(NPPBlockVoid)to completion:(NPPBlockVoid)block;
+ (void) moveSetFrom:(NPPBlockVoid)from completion:(NPPBlockVoid)block;
+ (void) moveSetFrom:(NPPBlockVoid)from to:(NPPBlockVoid)to completion:(NPPBlockVoid)block;

- (void) executeAfterAnimation:(NPPBlockVoid)block;

//*************************
//	View Manipulation
//*************************

- (void) toggleHidden;
- (void) removeSubviewWithTag:(unsigned int)tag;
- (void) removeSubviewAtIndex:(NSUInteger)index;
- (void) removeAllSubviews;
- (void) removeAllSubviewsWithTag:(unsigned int)tag;
- (void) removeFromSuperviewAfterAnimation;
- (void) removeAllGestures;

//*************************
//	Controllers
//*************************

- (UIView *) subviewWithTag:(NSInteger)tag;
- (UIView *) findFirstResponder;
+ (UIView *) findFirstResponder;

@end

#pragma mark -
#pragma mark UIScrollView Category
//**************************************************
//	UIScrollView Category
//**************************************************

@interface UIScrollView(NPPScrollView)

//*************************
//	Basic Movements
//*************************

- (float) contentOffsetX;
- (void) setContentOffsetX:(float)offsetX;

- (float) contentOffsetY;
- (void) setContentOffsetY:(float)offsetY;

- (float) contentWidth;
- (void) setContentWidth:(float)width;

- (float) contentHeight;
- (void) setContentHeight:(float)height;

- (void) setContentOffsetX:(float)offsetX animated:(BOOL)animated;
- (void) setContentOffsetY:(float)offsetY animated:(BOOL)animated;

//*************************
//	Customization
//*************************

+ (void) defineScrollbarHorizontal:(NSString *)horizontal vertical:(NSString *)vertical;

@end

#pragma mark -
#pragma mark CALayer Category
//**************************************************
//	CALayer Category
//**************************************************

@interface CALayer(NPPLayer)

//*************************
//	Basics
//*************************

- (CGPoint) pivot;
- (void) setPivot:(CGPoint)value;

@end

#pragma mark -
#pragma mark UIPageControl Category
//**************************************************
//	UIPageControl Category
//**************************************************

@interface UIPageControl(NPPPageControl)

//*************************
//	Customization
//*************************

+ (void) defineLayout:(NSString *)normal selected:(NSString *)selected;

@end