/*
 *	NPPScrollLabel.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 7/9/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPEffects.h"

@interface NPPScrollLabel : UIView <UIScrollViewDelegate>
{
@private
	UIScrollView				*_scrollView;
	
	NSArray						*_texts;
	NPPDirection				_scrollDirection;
	float						_scrollSpeed;
	float						_fadeLength;
	NSTimeInterval				_pauseInterval;
	NSInteger					_labelSpacing;
	BOOL						_scrolling;
}

@property (nonatomic) NPPDirection scrollDirection;		// Just left and right.
@property (nonatomic) float scrollSpeed;				// Default 30.0f
@property (nonatomic) float fadeLength;					// Default 15.0f
@property (nonatomic) NSTimeInterval pauseInterval;		// Default 0.0f
@property (nonatomic) NSInteger labelSpacing;			// Default 0.0f
@property (nonatomic, readonly) BOOL scrolling;

@property (nonatomic, NPP_RETAIN) NSArray *texts;
@property (nonatomic, readonly) unsigned int currentTextIndex;

@property (nonatomic, NPP_COPY) NSString *text;
@property (nonatomic, NPP_COPY) NSAttributedString *attributedText;
@property (nonatomic, NPP_RETAIN) UIFont *font;
@property (nonatomic, NPP_RETAIN) UIColor *textColor;
@property (nonatomic, NPP_RETAIN) UIColor *shadowColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) NSTextAlignment textAlignment;

- (void) refreshLabels;

- (void) scrollLabelIfNeeded;

@end
