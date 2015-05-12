/*
 *	NPPBadgeView.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 9/18/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPFont+UIFont.h"
#import "NPPLabel.h"

@interface NPPBadgeView : UIView
{
@private
	UIImageView				*_background;
	NPPLabel				*_labelNumber;
}

@property (nonatomic) int number;

- (id) initWithNumber:(int)value;

+ (id) badgeWithNumber:(int)value;
+ (id) badgeWithApplicationBadgeNumber;

@end