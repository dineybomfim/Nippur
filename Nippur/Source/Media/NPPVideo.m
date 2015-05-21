/*
 *	NPPVideo.m
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

#import "NPPVideo.h"

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

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPVideo()
{
	AVPlayer					*_player;
	AVPlayerItem				*_item;
	AVPlayerLayer				*_layer;
}

// Initializes a new instance.
- (void) initializing;

- (AVPlayer *) currentPlayer;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPVideo

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize looping = _isLooping;

@dynamic duration, currentTime;

- (double) duration { CMTime time = _item.duration; return time.value / time.timescale; }

- (double) currentTime { CMTime time = _item.currentTime; return time.value / time.timescale; }
- (void) setCurrentTime:(double)value
{
	[_item seekToTime:CMTimeMake(value, 1.0f)];
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super initWithFrame:CGRectZero]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithFile:(NSString *)named
{
	if ((self = [super initWithFrame:CGRectZero]))
	{
		[self initializing];
		[self loadFile:named];
	}
	
	return self;
}

+ (id) videoWithFile:(NSString *)named
{
	NPPVideo *video = [[self alloc] initWithFile:named];
	
	return nppAutorelease(video);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	// Allocating the new player.
	_player = [[AVPlayer alloc] init];
	_layer = [[AVPlayerLayer alloc] init];
	
	_layer.player = _player;
	[self.layer addSublayer:_layer];
}

- (AVPlayer *) currentPlayer
{
	return _player;
}

- (void) notificationHandler:(NSNotification *)notification
{
	BOOL willLoop = _isLooping;
	
	if ([[notification name] isEqualToString:AVPlayerItemDidPlayToEndTimeNotification])
	{
		// Updates the willLoop option based on delegate implementation.
		if ([_delegate respondsToSelector:@selector(videoShouldLoop:)])
		{
			willLoop = [_delegate videoShouldLoop:self];
		}
		
		// Looping the source.
		if (willLoop)
		{
			self.currentTime = 0.0;
			[_player play];
		}
		// Ending the source.
		else
		{
			[self stop];
		}
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) loadFile:(NSString *)named
{
	NSArray *tracks = nil;
	AVURLAsset *asset = nil;
	CGRect frame = CGRectZero;
	
	nppRelease(_item);
	
	// Allocating the new item.
	asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:nppMakePath(named)] options:nil];
	_item = [[AVPlayerItem alloc] initWithAsset:asset];
	
	if ([_item error] == nil && [_item status] != AVPlayerItemStatusFailed)
	{
		// Gets the size of the first track.
		tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
		if ([tracks count] > 0)
		{
			frame.size = [[tracks objectAtIndex:0] naturalSize];
		}
		
		CGRect selfFrame = self.frame;
		
		// Adjusting the view based on the new item.
		selfFrame.size = frame.size;
		self.frame = selfFrame;
		_layer.frame = frame;
		_layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		_layer.needsDisplayOnBoundsChange = YES;
		[_player replaceCurrentItemWithPlayerItem:_item];
		
		// Item notification.
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center removeObserver:self];
		[center addObserver:self
				   selector:@selector(notificationHandler:)
					   name:AVPlayerItemDidPlayToEndTimeNotification
					 object:_item];
	}
}

- (void) play
{
	if ([_delegate respondsToSelector:@selector(videoWillStart:)])
	{
		[_delegate videoWillStart:self];
	}
	
	[_player play];
}

- (void) pause
{
	if ([_delegate respondsToSelector:@selector(videoWillPause:)])
	{
		[_delegate videoWillPause:self];
	}
	
	[_player pause];
}

- (void) stop
{
	if ([_delegate respondsToSelector:@selector(videoWillEnd:)])
	{
		[_delegate videoWillEnd:self];
	}
	
	[_player pause];
	self.currentTime = self.duration;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

+ (UIImage *) snapshotForView:(UIView *)view inRect:(CGRect)rect
{
	UIImage *image = nil;
	
	if ([view isKindOfClass:[NPPVideo class]])
	{
		AVPlayerItem *item = [[(NPPVideo *)view currentPlayer] currentItem];
		AVAsset *asset = item.asset;
		AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
		CGImageRef thumb = [generator copyCGImageAtTime:item.currentTime actualTime:NULL error:NULL];
		
		image = [UIImage imageWithCGImage:thumb];
		
		nppCFRelease(thumb);
	}
	
	return image;
}

- (void) dealloc
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self];
	
	nppRelease(_player);
	nppRelease(_layer);
	nppRelease(_item);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end
