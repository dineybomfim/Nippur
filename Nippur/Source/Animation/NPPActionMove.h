/*
 *	NPPActionMove.h
 *	Nippur
 *
 *	The Nippur is a framework for iOS to make daily work easier and more reusable.
 *	This Nippur contains many API and includes many wrappers to other Apple frameworks.
 *
 *	More information at the official web site: http://db-in.com/nippur
 *
 *	Created by Diney Bomfim on 8/12/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NPPAction.h"

typedef enum
{
	NPPMoveTypeBy,
	NPPMoveTypeTo,
	NPPMoveTypeFrom,
	NPPMoveTypeFromTo,
} NPPMoveType;

typedef float (*NPPEase)(float begin, float change, float time, float duration);

/*!
 *					<strong>(Internal only)</strong> Class cluster for #NPPAction#.
 */
@interface NPPActionMove : NPPAction
{
@protected
	// Helpers
	NSMutableDictionary			*_tracker;
	NPPEase						_easingFunc;
	
	// Structure
	NSString					*_key;
	float						_from;
	float						_to;
	NPPMoveType					_type;
}

- (void) setKey:(NSString *)key from:(float)fromValue to:(float)toValue type:(NPPMoveType)type;

@end