/*
 *	NPPLabel.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 2/28/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPFont+UIFont.h"

@interface NPPLabel : UILabel
{
@private
}

@property (nonatomic) UIEdgeInsets edgeInsets;
@property (nonatomic) int intText;
@property (nonatomic) float floatText;

- (id) initWithCenterString:(NSString *)string font:(UIFont *)font maxWidth:(float)width;

+ (id) labelRegular:(NSString *)title fontSize:(float)pointSize maxWidth:(float)width;
+ (id) labelBold:(NSString *)title fontSize:(float)pointSize maxWidth:(float)width;
+ (id) labelItalic:(NSString *)title fontSize:(float)pointSize maxWidth:(float)width;

+ (void) defineLabelEdgeInsets:(UIEdgeInsets)value;

@end