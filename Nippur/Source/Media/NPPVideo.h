/*
 *	NPPVideo.h
 *	Nippur
 *	v1.0
 *
 *	Created by Diney Bomfim on 8/10/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NippurCore.h"

#import <AVFoundation/AVFoundation.h>

@class NPPVideo;

@protocol NPPVideoDelegate <NSObject>

@optional
- (void) videoWillStart:(NPPVideo *)video;
- (void) videoWillPause:(NPPVideo *)video;
- (void) videoWillEnd:(NPPVideo *)video;
- (BOOL) videoShouldLoop:(NPPVideo *)video;

@end

@interface NPPVideo : UIView
{
@private
	BOOL						_isLooping;
	NPP_ARC_ASSIGN id <NPPVideoDelegate>		_delegate;
}

@property (nonatomic, readonly) double duration; // In seconds.
@property (nonatomic) double currentTime; // In seconds.
@property (nonatomic, getter = isLooping) BOOL looping;

@property (nonatomic, NPP_ASSIGN) id <NPPVideoDelegate> delegate;

- (id) initWithFile:(NSString *)named;
+ (id) videoWithFile:(NSString *)named;

- (void) loadFile:(NSString *)named;

- (void) play;
- (void) pause;
- (void) stop;

@end