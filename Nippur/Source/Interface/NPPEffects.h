/*
 *	NPPEffects.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 9/30/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPImage+UIImage.h"

@interface NPPBackdropView : UIView

@property (nonatomic) BOOL autoUpdate;	// Default is YES.
@property (nonatomic) float blurRadius;	// Default is 4.0
@property (nonatomic, NPP_RETAIN) UIView *blurredView;

// Forces an update.
- (void) updateBlur;

@end

@interface UIView(NPPEffects)

//*************************
//	Graphics
//*************************

- (NPPImage *) snapshot;
- (NPPImage *) snapshotInRect:(CGRect)rect;

//*************************
//	Graphics
//*************************

- (void) efxAddShineTo:(NPPDirection)direction color:(UIColor *)color duration:(float)seconds;
- (void) efxRemoveShine;

@end