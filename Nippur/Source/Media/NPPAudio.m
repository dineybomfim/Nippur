/*
 *	NPPAudio.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 11/6/11.
 *	Copyright 2011 db-in. All rights reserved.
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
		NSData *data = nppDataFromFile(named);
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