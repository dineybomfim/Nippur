/*
 *	NPPVideo.h
 *	Copyright (c) 2011-2015 db-in. More information at: http://db-in.com
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