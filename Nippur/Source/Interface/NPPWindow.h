/*
 *	NPPWindow.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 9/2/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

@interface NPPWindow : UIWindow
{
@private
	BOOL					_avoidKeyWindow;
}

// Default is NO.
@property (nonatomic) BOOL avoidKeyWindow;

@end