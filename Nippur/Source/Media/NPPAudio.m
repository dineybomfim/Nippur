/*
 *	NPPAudio.m
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

#import "NPPAudio.h"

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

NPP_STATIC_READONLY(nppSoundsLibrary, NSMutableDictionary);

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPAudio() <AVAudioPlayerDelegate>

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPAudio

NPP_SINGLETON_IMPLEMENTATION(NPPAudio);

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

- (void) playSound:(NSString *)named volume:(float)volume repeat:(unsigned int)repeat
{
	//*
	if (named != nil)
	{
		NSMutableDictionary *sounds = nppSoundsLibrary();
		NSData *data = [NSData dataWithContentsOfFile:nppMakePath(named)];
		AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:nil];
		
		player.delegate = self;
		player.numberOfLoops = repeat;
		player.volume = volume;
		[player play];
		
		if (player != nil)
		{
			// Releases previous sound like this.
			[sounds setObject:player forKey:named];
		}
		
		nppRelease(player);
	}
	
	/*/
	if (named != nil)
	{
		NSURL *fullPath = [NSURL fileURLWithPath:nppMakePath(named)];
		
		SystemSoundID sound = 0;
		AudioServicesCreateSystemSoundID((NPP_ARC_BRIDGE CFURLRef)fullPath, &sound);
		
		AudioServicesPlaySystemSound(sound);
	}
	//*/
}

- (void) playSound:(NSString *)named volume:(float)volume orVibrate:(BOOL)vibrate
{
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	float currentVolume = audioSession.outputVolume;
	
	if (currentVolume < 0.1f && vibrate)
	{
		[NPPAudio vibrate];
	}
	else
	{
		[self playSound:named volume:volume repeat:0];
	}
}

- (void) stopSound:(NSString *)path
{
	//*
	NSMutableDictionary *sounds = nppSoundsLibrary();
	AVAudioPlayer *player = [nppSoundsLibrary() objectForKey:path];
	
	if (player != nil)
	{
		[player stop];
		[sounds removeObjectForKey:path];
	}
	/*/
	//*/
}

- (void) stopAllSounds
{
	
}

#pragma mark -
#pragma mark Audio Deleate
//*************************
//	Audio Deleate
//*************************

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	//*
	NSMutableDictionary *sounds = nppSoundsLibrary();
	NSString *named = nppGetFile(player.url.absoluteString);
	
	if (named != nil)
	{
		[sounds removeObjectForKey:named];
	}
	/*/
	//*/
}

+ (void) defineSession:(NSString *)session
{
	//*
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	
	session = (session == nil) ? AVAudioSessionCategoryAmbient : session;
	[audioSession setCategory:session error:nil];
	[audioSession setActive:YES error:nil];
	/*/
	//*/
}

+ (void) vibrate
{
	//AudioServicesPlaySystemSound
	AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (void) initialize
{
	if (self == [NPPAudio class])
	{
		[self defineSession:nil];
	}
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end