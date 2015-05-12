/*
 *	NPPAudio.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 11/6/11.
 *	Copyright 2011 db-in. All rights reserved.
 */

#import "NippurCore.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface NPPAudio : NSObject

NPP_SINGLETON_INTERFACE(NPPAudio);

// repeat 0 = 1 play, -1 = inifinity.
// volume [0.0, 1.0]
- (void) playSound:(NSString *)named volume:(float)volume repeat:(unsigned int)repeat;
- (void) playSound:(NSString *)named volume:(float)volume orVibrate:(BOOL)vibrate;

- (void) stopSound:(NSString *)named;

- (void) stopAllSounds;

// AVAudioSessionCategoryAmbient is the default.
+ (void) defineSession:(NSString *)session;

+ (void) vibrate;

@end