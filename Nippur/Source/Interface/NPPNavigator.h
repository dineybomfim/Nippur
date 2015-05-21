/*
 *	NPPNavigator.h
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

/*!
 *					Defines the navigation type.
 *
 *						- NPPPageModeNormal: Normal navigation via push controller.
 *						- NPPPageModeAlwaysBase: Requires always the base level.
 *						- NPPPageModeSimpleModal: Requires at least one modal level.
 *						- NPPPageModeAlwaysModal: Always requires a new modal level.
 */
typedef NS_OPTIONS(NSUInteger, NPPPageMode)
{
	NPPPageModeNormal,
	NPPPageModeAlwaysBase,
	NPPPageModeSimpleModal,
	NPPPageModeAlwaysModal,
	NPPPageModeOverlay,
};

/*!
 *					Defines the methods that can be implemented by the ViewControllers to instruct the
 *					navigator about the navigation type.
 */
@protocol NPPNavigationPage

@optional
- (NPPPageMode) pageMode;
- (UIColor *) pageColor;

@end

@interface NPPNavigator : UINavigationController
{
@private
	UINavigationController		*_currentNavigation;
	NSMutableArray				*_navigations;
	UIView						*_backgroundView;
	
	// *** TabBar
	NSMutableArray				*_tabbars;
}

NPP_SINGLETON_INTERFACE(NPPNavigator);

@property (nonatomic, readonly) NSString *currentPage;
@property (nonatomic, readonly) UIViewController *currentController;
@property (nonatomic, NPP_RETAIN) UIView *backgroundView;

- (void) navigateBack;
- (void) navigateToBaseLevel;
- (void) navigateToTabBarIndex:(NSUInteger)index;
- (void) navigateTo:(NSString *)pageNamed;

// TabBar routines.
- (void) defineTabBarPages:(NSArray *)pages;

@end