/*
 *	NPPCamera.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 3/1/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NippurCore.h"

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>

typedef enum
{
	NPPCameraSourceBack,
	NPPCameraSourceFront,
} NPPCameraSource;

@interface NPPCamera : NSObject

NPP_SINGLETON_INTERFACE(NPPCamera);

@property (nonatomic) NPPCameraSource camera; // The default is the back camera.
@property (nonatomic) CGSize size;

- (void) reset;
- (void) startRecording;
- (void) stopRecording;
- (BOOL) isRecording;

- (void) showPreviewInView:(UIView *)view;
- (void) hidePreviewInView:(UIView *)view;

- (UIImage *) snapshot;

- (void) focusAtPoint:(CGPoint)point;
- (void) exposureAtPoint:(CGPoint)point;

@end