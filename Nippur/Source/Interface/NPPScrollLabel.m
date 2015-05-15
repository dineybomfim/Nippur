/*
 *	NPPScrollLabel.m
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

#import "NPPScrollLabel.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_LABEL_COUNT				2
#define NPP_LABEL_FADE				15.0f
#define NPP_LABEL_SPACING			0.0f
#define NPP_LABEL_SPEED				30.0f
#define NPP_LABEL_PAUSE				0.0f

#define NPP_LABEL(a, v) nppLabelPerformOnArray(self.labels, ^(UILabel *label) { label.a = v; })

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

static void nppLabelPerformOnArray(NSArray *objects, void (^block)(id object))
{
	id obj = nil;
	
	for (obj in objects)
	{
		block(obj);
	}
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPScrollLabel()

- (void) initializing;

@property (nonatomic, NPP_RETAIN) NSArray *labels;
@property (nonatomic, readonly) UILabel *mainLabel;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPScrollLabel

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize pauseInterval = _pauseInterval, scrolling = _scrolling, labelSpacing = _labelSpacing,
			labels = _labels;

@dynamic fadeLength, text, mainLabel, shadowColor, shadowOffset, texts, currentTextIndex;

- (UILabel *) mainLabel { return [_labels firstObject]; }

- (float) fadeLength { return _fadeLength; }
- (void) setFadeLength:(float)value
{
	_fadeLength = value;
	[self refreshLabels];
	[self fadeAlphaAt:NPPDirectionLeft startAt:0.0f endAt:_fadeLength mirror:YES];
}

- (NSString *) text { return self.mainLabel.text; }
- (void) setText:(NSString *)value
{
	NPP_LABEL(text, value);
	[self refreshLabels];
}

- (NSAttributedString *) attributedText { return self.mainLabel.attributedText; }
- (void) setAttributedText:(NSAttributedString *)value
{
	NPP_LABEL(attributedText, value);
	[self refreshLabels];
}

- (UIColor *) textColor { return self.mainLabel.textColor; }
- (void) setTextColor:(UIColor *)value
{
	NPP_LABEL(textColor, value);
}

- (UIFont *) font { return self.mainLabel.font; }
- (void) setFont:(UIFont *)value
{
	NPP_LABEL(font, value);
	[self refreshLabels];
}

- (float) scrollSpeed { return _scrollSpeed; }
- (void) setScrollSpeed:(float)value
{
	_scrollSpeed = value;
	[self scrollLabelIfNeeded];
}

- (NPPDirection) scrollDirection { return _scrollDirection; }
- (void) setScrollDirection:(NPPDirection)value
{
	_scrollDirection = value;
	[self scrollLabelIfNeeded];
}

- (UIColor *) shadowColor { return self.mainLabel.shadowColor; }
- (void) setShadowColor:(UIColor *)value
{
	NPP_LABEL(shadowColor, value);
}

- (CGSize) shadowOffset { return self.mainLabel.shadowOffset; }
- (void) setShadowOffset:(CGSize)offset
{
	NPP_LABEL(shadowOffset, offset);
}

- (NSTextAlignment) textAlignment { return self.mainLabel.textAlignment; }
- (void) setTextAlignment:(NSTextAlignment)value
{
	NPP_LABEL(textAlignment, value);
}

- (NSArray *) texts { return _texts; }
- (void) setTexts:(NSArray *)value
{
	if (_texts != value)
	{
		nppRelease(_texts);
		_texts = nppRetain(value);
		
		NSString *text = nil;
		NSMutableString *longText = [[NSMutableString alloc] init];
		
		for (text in _texts)
		{
			[longText appendFormat:@"%@      |      ", text];
		}
		
		self.text = longText;
		
		nppRelease(longText);
	}
}

- (unsigned int) currentTextIndex
{
	NSString *text = nil;
	NSString *string = nil;
	CGSize size = CGSizeZero;
	UIFont *font = self.mainLabel.font;
	float halfWidth = self.width * 0.5f;
	float posX = 0.0f;
	unsigned int i = 0;
	
	for (text in _texts)
	{
		string = [NSString stringWithFormat:@"%@      |      ", text];
		size = [string sizeWithFont:font
							minSize:font.pointSize
						   forWidth:NPP_MAX_16
						  lineBreak:0];
		
		posX += size.width;
		
		if (posX >= _scrollView.contentOffsetX + halfWidth)
		{
			break;
		}
		
		++i;
	}
	
	return (i >= _texts.count) ? 0 : i;
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

- (id) initWithCoder:(NSCoder *) aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithFrame:(CGRect) frame
{
	if ((self = [super initWithFrame:frame]))
	{
		[self initializing];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	// create the labels
	_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	_scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	_scrollView.backgroundColor = [UIColor clearColor];
	
	[self addSubview:_scrollView];
	
	NSMutableSet *labelSet = [[NSMutableSet alloc] initWithCapacity:NPP_LABEL_COUNT];
	
	for (int index = 0 ; index < NPP_LABEL_COUNT ; ++index)
	{
		UILabel *label = [[UILabel alloc] init];
		label.backgroundColor = [UIColor clearColor];
		label.autoresizingMask = self.autoresizingMask;
		
		// store labels
		[_scrollView addSubview:label];
		[labelSet addObject:label];
		
		nppRelease(label);
	}
	
	self.labels = nppAutorelease([[labelSet allObjects] copy]);
	nppRelease(labelSet);
	
	// default values
	_scrollDirection = NPPDirectionLeft;
	_scrollSpeed = NPP_LABEL_SPEED;
	self.pauseInterval = NPP_LABEL_PAUSE;
	self.labelSpacing = NPP_LABEL_SPACING;
	self.textAlignment = NSTextAlignmentLeft;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.scrollEnabled = NO;
	self.userInteractionEnabled = NO;
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = YES;
	self.fadeLength = NPP_LABEL_FADE;
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) scrollLabelIfNeeded
{
	if (!self.text.length)
		return;
	
	CGFloat labelWidth = CGRectGetWidth(self.mainLabel.bounds);
	if (labelWidth <= CGRectGetWidth(self.bounds))
		return;
	
	BOOL doScrollLeft = (self.scrollDirection == NPPDirectionLeft);
	_scrollView.contentOffsetX = (doScrollLeft) ? 0.0f : labelWidth + self.labelSpacing;
	
	// animate the scrolling
	NSTimeInterval duration = labelWidth / self.scrollSpeed;
	
	__block id bself = self;
	float finalX = (doScrollLeft) ? labelWidth + self.labelSpacing : 0.0f;
	NPPAction *moveX = [NPPAction moveKey:@"contentOffsetX" to:finalX duration:duration];
	NPPAction *sequence = [NPPAction sequence:@[ [NPPAction waitForDuration:self.pauseInterval], moveX ]];
	
	NPPBlockVoid block = ^(void)
	{
		_scrolling = NO;
		
		// remove the left shadow
		[bself scrollLabelIfNeeded];
	};
	
	[_scrollView removeAllActions];
	[_scrollView runAction:sequence completion:block];
}

- (void) refreshLabels
{
	__block float offset = 0;
	
	// calculate the label size
	CGSize labelSize = [self.mainLabel.text sizeWithFont:self.mainLabel.font
											 constrained:CGSizeMake(CGFLOAT_MAX, self.height)
											   lineBreak:0];
	
	nppLabelPerformOnArray(self.labels, ^(UILabel *label) {
		CGRect frame = label.frame;
		frame.origin.x = offset;
		frame.size.height = CGRectGetHeight(self.bounds);
		frame.size.width = labelSize.width + 2.f /*Magic number*/;
		label.frame = frame;
		
		// Recenter label vertically within the scroll view
		label.center = CGPointMake(label.center.x, roundf(self.center.y - CGRectGetMinY(self.frame)));
		
		offset += CGRectGetWidth(label.bounds) + self.labelSpacing;
	});
	
	_scrollView.contentOffset = CGPointZero;
	
	// if the label is bigger than the space allocated, then it should scroll
	if (CGRectGetWidth(self.mainLabel.bounds) > CGRectGetWidth(self.bounds) )
	{
		CGSize size;
		size.width = self.mainLabel.width + self.width + self.labelSpacing;
		size.height = CGRectGetHeight(self.bounds);
		_scrollView.contentSize = size;
		
		NPP_LABEL(hidden, NO);
		
		[self fadeAlphaAt:NPPDirectionLeft startAt:0.0f endAt:_fadeLength mirror:YES];
		
		[self scrollLabelIfNeeded];
	}
	else
	{
		// Hide the other labels
		NPP_LABEL(hidden, (self.mainLabel != label));
		
		// adjust the scroll view and main label
		_scrollView.contentSize = self.bounds.size;
		self.mainLabel.frame = self.bounds;
		self.mainLabel.hidden = NO;
		
		[self fadeAlphaAt:NPPDirectionLeft startAt:0.0f endAt:0.0f mirror:YES];
	}
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self fadeAlphaAt:NPPDirectionLeft startAt:0.0f endAt:_fadeLength mirror:YES];
}

- (void) dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	nppRelease(_scrollView);
	nppRelease(_labels);
	nppRelease(_texts);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end
