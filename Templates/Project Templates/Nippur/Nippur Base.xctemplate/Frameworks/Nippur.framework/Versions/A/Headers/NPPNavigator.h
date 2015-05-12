/*
 *	NPPNavigator.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 8/17/12.
 *	Copyright 2012 db-in. All rights reserved.
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
typedef enum
{
	NPPPageModeNormal,
	NPPPageModeAlwaysBase,
	NPPPageModeSimpleModal,
	NPPPageModeAlwaysModal,
	NPPPageModeOverlay,
} NPPPageMode;

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
	BOOL						_fullScreen;
	
	// *** TabBar
	NSMutableArray				*_tabbars;
}

NPP_SINGLETON_INTERFACE(NPPNavigator);

@property (nonatomic, readonly) NSString *currentPage;
@property (nonatomic, readonly) UIViewController *currentController;
@property (nonatomic, NPP_RETAIN) UIView *backgroundView;
@property (nonatomic, getter = isFullScreen) BOOL fullScreen;

- (void) navigateBack;
- (void) navigateToBaseLevel;
- (void) navigateToTabBarIndex:(NSUInteger)index;
- (void) navigateTo:(NSString *)pageNamed;

// Full screen will make the entire application goes full screen, that means it will lie behind status bar.
- (void) setFullScreen:(BOOL)fullScreen animated:(BOOL)animated;

// TabBar routines.
- (void) defineTabBarPages:(NSArray *)pages;

@end