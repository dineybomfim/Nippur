/*
 *	NPPScrollLabel.h
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

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPPluginFont.h"
#import "NPPPluginView.h"
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
