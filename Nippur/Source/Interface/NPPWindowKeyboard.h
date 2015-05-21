/*
 *	NPPWindowKeyboard.h
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

#import "NPPView+UIView.h"
#import "NPPWindow.h"

@interface NPPWindowKeyboard : UIViewController
{
@private
	BOOL					_autoAdjustToKeyboard;
	float					_heightExtra;
	CGRect					_validFrame;
	UIView					*_holderView;
	NPPWindow				*_window;
}

NPP_SINGLETON_INTERFACE(NPPWindowKeyboard);

@property (nonatomic) BOOL autoAdjustToKeyboard; // Default YES.
@property (nonatomic) float heightWindow; // Default equals to current UIKeyboard.
@property (nonatomic) float heightExtra; // Default 0.
@property (nonatomic, readonly) CGRect frameFull;

- (void) addView:(UIView *)view;
- (void) addView:(UIView *)view atIndex:(int)index;
- (void) removeView:(UIView *)view;
- (void) removeViewAtIndex:(int)index;

- (unsigned int) viewsCount;

- (void) showAnimated:(BOOL)animated completion:(NPPBlockVoid)block;
- (void) hideAnimated:(BOOL)animated completion:(NPPBlockVoid)block;

@end