/*
 *	NPPNavigator.m
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

#import "NPPNavigator.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static UIViewController *nppGetPreviusController(NSArray *navigations, Class newClass)
{
	id item = nil;
	UINavigationController *navigation = nil;
	
	// Check if the class is already in the view controllers.
	for (navigation in navigations)
	{
		for (item in [navigation viewControllers])
		{
			if ([item class] == newClass)
			{
				return item;
			}
		}
	}
	
	return nil;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPNavigator()

// Initializes a new instance.
- (void) initializing;

- (void) rotateBackgroundsToOrientation:(UIInterfaceOrientation)orientation;
- (void) rotateBackgroundViewController:(UIViewController *)controller
						  toOrientation:(UIInterfaceOrientation)orientation;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPNavigator

NPP_SINGLETON_IMPLEMENTATION(NPPNavigator);

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@dynamic currentPage, currentController, backgroundView;

- (NSString *) currentPage
{
	return NSStringFromClass([[self currentController] class]);
}

- (UIViewController *) currentController
{
	return [_currentNavigation visibleViewController];
}

- (UIView *) backgroundView { return _backgroundView; }
- (void) setBackgroundView:(UIView *)value
{
	if (_backgroundView != value)
	{
		[_backgroundView removeFromSuperview];
		
		nppRelease(_backgroundView);
		_backgroundView = nppRetain(value);
		
		if (_backgroundView != nil)
		{
			[[self view] insertSubview:_backgroundView atIndex:0];
		}
	}
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super initWithNibName:nil bundle:nil]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithRootViewController:(UIViewController *)rootViewController
{
	if ((self = [super initWithRootViewController:rootViewController]))
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
	//self.navigationBarHidden = YES;
	
	// Navigations.
	_currentNavigation = self;
	_navigations = [[NSMutableArray alloc] initWithObjects:_currentNavigation, nil];
	
	// *** TabBar
	_tabbars = [[NSMutableArray alloc] init];
}

- (void) rotateBackgroundsToOrientation:(UIInterfaceOrientation)orientation
{
	UINavigationController *navigation = nil;
	UIViewController *controller = nil;
	BOOL canRotate = NO;
	int i = 0;
	int count = (int)[_navigations count] - 1;
	
	for (i = 0; i < count; ++i)
	{
		navigation = [_navigations objectAtIndex:i];
		controller = [[navigation viewControllers] lastObject];
		
		// Only for view controllers in background and that are showing a modal in current context.
		if (controller != [navigation visibleViewController] &&
			navigation.modalPresentationStyle == UIModalPresentationCurrentContext)
		{
			/*
			 if (nppDeviceOSVersion() >= 6.0f)
			 {
			 canRotate = [controller shouldAutorotate];
			 }
			 else
			 {
			 canRotate = [controller shouldAutorotateToInterfaceOrientation:orientation];
			 }
			 /*/
			canRotate = YES;
			//*/
			
			if (canRotate)
			{
				[self rotateBackgroundViewController:controller toOrientation:orientation];
			}
		}
	}
}

- (void) rotateBackgroundViewController:(UIViewController *)controller
						  toOrientation:(UIInterfaceOrientation)orientation
{
	//*
	float rotationAngle = 0.0f;
	float width = 0.0f;
	float height = 0.0f;
	CGSize size = self.view.size;
	
	switch (orientation)
	{
		case UIInterfaceOrientationLandscapeLeft:
			rotationAngle = -90.0f;
			width = size.height;
			height = size.width;
			break;
		case UIInterfaceOrientationLandscapeRight:
			rotationAngle = 90.0f;
			width = size.height;
			height = size.width;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			rotationAngle = 180.0f;
			width = size.width;
			height = size.height;
			break;
		case UIInterfaceOrientationPortrait:
		default:
			rotationAngle = 0.0f;
			width = size.width;
			height = size.height;
			break;
	}
	
	NPPBlockVoid animation = ^(void)
	{
		UIView *view = controller.view;
		//view.rotateZ = rotationAngle;
		view.rotation = rotationAngle;
		view.bounds = CGRectMake(0.0, 0.0, width, height);
	};
	
	[UIView animateWithDuration:kNPPAnimTime animations:animation completion:nil];
	/*/
	UIDeviceOrientation devorientation = [UIDevice currentDevice].orientation;
	CGFloat rotationAngle = 0;
	
	if (devorientation == UIDeviceOrientationPortraitUpsideDown) rotationAngle = M_PI;
	else if (devorientation == UIDeviceOrientationLandscapeLeft) rotationAngle = M_PI_2;
	else if (devorientation == UIDeviceOrientationLandscapeRight) rotationAngle = -M_PI_2;
	
	[UIView animateWithDuration:0.5 animations:^{
		self.view.transform = CGAffineTransformMakeRotation(rotationAngle);
		self.view.transform = CGAffineTransformMakeRotation(rotationAngle);
		self.view.transform = CGAffineTransformMakeRotation(rotationAngle);
	} completion:nil];
	
	//adjust view frame based on screen size
	
	if(devorientation == UIInterfaceOrientationLandscapeLeft ||
	   devorientation == UIInterfaceOrientationLandscapeRight)
	{
		self.view.bounds = CGRectMake(0.0, 0.0, 568, 320);
	}
	else
	{
		self.view.bounds = CGRectMake(0.0, 0.0, 320, 568);
	}
	//*/
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (void) navigateBack
{
	Class lastClass;
	UINavigationController *navigation;
	navigation = [_navigations lastObject];
	NSUInteger count = [[navigation viewControllers] count];
	
	// Checks if the top most navigation has more than 1 ViewController. If so, navigate back.
	if (count > 1)
	{
		// Get the next-to-last controller.
		lastClass = [[[navigation viewControllers] objectAtIndex:count - 2] class];
	}
	// Otherwise, goes back to the next-to-last navigation.
	else
	{
		count = [_navigations count];
		
		// Get the next-to-last navigation.
		navigation = [_navigations objectAtIndex:(count > 1) ? count - 2 : 0];
		lastClass = [[[navigation viewControllers] lastObject] class];
	}
	
	[self navigateTo:NSStringFromClass(lastClass)];
}

- (void) navigateToBaseLevel
{
	static BOOL goingBase = NO;
	
	Class lastClass = NULL;
	UINavigationController *navigation = [_navigations objectAtIndex:0];
	
	// Avoids recursive loops or if the current navigation is already the base level.
	if (!goingBase && navigation != _currentNavigation)
	{
		// Locks the base navigation for a while.
		goingBase = YES;
		
		lastClass = [[[navigation viewControllers] lastObject] class];
		[self navigateTo:NSStringFromClass(lastClass)];
		
		// Unlocks the base navigation for a while.
		goingBase = NO;
	}
}

- (void) navigateToTabBarIndex:(NSUInteger)index
{
	[self navigateTo:[_tabbars objectAtIndex:index]];
}

- (void) navigateTo:(NSString *)pageNamed
{
	BOOL hasViewController = NO;
	BOOL isTabBarController = [_tabbars containsObject:pageNamed];
	UIViewController *controller = nil;
	UINavigationController *navigation = nil;
	UINavigationController *parentNavigation = nil;
	Class newClass = NULL;
	
	// Chooses the page class.
	if (pageNamed == nil || [pageNamed isEqualToString:[self currentPage]])
	{
		return;
	}
	else
	{
		newClass = NSClassFromString(pageNamed);
		
		// *** TabBar
		if (isTabBarController)
		{
			newClass = [UITabBarController class];
		}
	}
	
	controller = nppGetPreviusController(_navigations, newClass);
	
	// Working with a new/old controller.
	if (controller != nil)
	{
		hasViewController = YES;
		parentNavigation = [controller navigationController];
	}
	else
	{
		hasViewController = NO;
		parentNavigation = [_navigations lastObject];
		controller = nppAutorelease([[newClass alloc] init]);
		
		// *** TabBar
		if (isTabBarController)
		{
			NSString *page = nil;
			NSMutableArray *tabBarItems = [NSMutableArray array];
			UIViewController *internalController = nil;
			UITabBarController *tabController = (UITabBarController *)controller;
			
			for (page in _tabbars)
			{
				internalController = [[NSClassFromString(page) alloc] init];
				[tabBarItems addObject:internalController];
				nppRelease(internalController);
			}
			
			tabController.tabBar.hidden = YES;
			tabController.viewControllers = tabBarItems;
		}
	}
	
	// *** TabBar
	if (isTabBarController)
	{
		NSString *page = nil;
		UITabBarController *tabController = (UITabBarController *)controller;
		NSUInteger index = 0;
		NSUInteger selected = 0;
		
		for (page in _tabbars)
		{
			if ([page isEqualToString:pageNamed])
			{
				selected = index;
			}
			
			++index;
		}
		
		tabController.selectedIndex = selected;
	}
	
	//*************************
	//	Page Settings
	//*************************
	
	// Default color.
	if ([controller respondsToSelector:@selector(pageColor)])
	{
		controller.view.backgroundColor = [(id <NPPNavigationPage>)controller pageColor];
	}
	
	// Gets the page navigation type.
	BOOL isModal = NO;
	if ([controller respondsToSelector:@selector(pageMode)])
	{
		NPPPageMode type = [(id <NPPNavigationPage>)controller pageMode];
		
		switch (type)
		{
			case NPPPageModeOverlay:
				_currentNavigation.modalPresentationStyle = UIModalPresentationCurrentContext;
				isModal = YES;
				break;
			case NPPPageModeSimpleModal:
				_currentNavigation.modalPresentationStyle = UIModalPresentationFullScreen;
				isModal = ([self presentedViewController] == nil);
				break;
			case NPPPageModeAlwaysModal:
				_currentNavigation.modalPresentationStyle = UIModalPresentationFullScreen;
				isModal = YES;
				break;
			case NPPPageModeAlwaysBase:
				//TODO navigating to the base can cause zombies, check it out.
				//[self navigateToBaseLevel];
				break;
			case NPPPageModeNormal:
			default:
				break;
		}
	}
	
	if (controller == [self currentController])
	{
		return;
	}
	
	//*************************
	//	Animation & Structure
	//*************************
	
	// Animate and navigate to the target view controller.
	if (hasViewController)
	{
		while ((navigation = [_navigations lastObject]))
		{
			if (navigation == parentNavigation && [self currentController] != controller)
			{
				if ([[navigation viewControllers] lastObject] != controller)
				{
					[_currentNavigation popToViewController:controller animated:YES];
				}
				break;
			}
			else if ([_navigations count] >= 2)
			{
				_currentNavigation = [_navigations objectAtIndex:[_navigations count] - 2];
				[_currentNavigation dismissViewControllerAnimated:YES completion:nil];
				[_navigations removeLastObject];
			}
		}
	}
	else
	{
		if (isModal && [_currentNavigation presentedViewController] == nil)
		{
			navigation = [[UINavigationController alloc] initWithRootViewController:controller];
			navigation.navigationBarHidden = YES;
			
			[_currentNavigation presentViewController:navigation animated:YES completion:nil];
			
			_currentNavigation = navigation;
			[_navigations addObject:navigation];
			
			nppRelease(navigation);
		}
		else
		{
			[_currentNavigation pushViewController:controller animated:YES];
		}
	}
}

// *** TabBar
- (void) defineTabBarPages:(NSArray *)pages
{
	[_tabbars removeAllObjects];
	[_tabbars setArray:pages];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

//TODO, rotation problem not solved yet. When a overlay view comes in and out, it break the background.
//*
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	BOOL canRotate = [super shouldAutorotateToInterfaceOrientation:orientation];
	
	if (canRotate)
	{
		[self rotateBackgroundsToOrientation:orientation];
	}
	
	return canRotate;
}

- (BOOL) shouldAutorotate
{
	BOOL canRotate = [super shouldAutorotate];
	
	if (canRotate)
	{
		[self rotateBackgroundsToOrientation:self.interfaceOrientation];
		//[self rotateBackgroundViewController:[[[_navigations firstObject] viewControllers] firstObject]
		//					   toOrientation:self.interfaceOrientation];
	}
	
	return canRotate;
}
//*/

/*
-(void) _updateLastKnownInterfaceOrientationOnPresentionStack:(UIInterfaceOrientation)orientation
{
	//struct objc_super superInfo = { self, [self superclass] };
	//nppLog(@"[[subclass super] a]:%@",objc_msgSendSuper(&superInfo, @selector(a)));
	
	//objc_msgSendSuper(&superInfo, @selector(_updateLastKnownInterfaceOrientationOnPresentionStack), orientation);
	//[super _updateLastKnownInterfaceOrientationOnPresentionStack:orientation];
	
	[self rotateBackgroundsToOrientation:orientation];
}
//*/

//- (id)_viewControllerForSupportedInterfaceOrientations
//{
//	nppLog(@"%@", [super _viewControllerForSupportedInterfaceOrientations]);
//	return self;
//}

//- (id)_viewControllerForRotation
//{
//	nppLog(@"%@", [super _viewControllerForRotation]);
//	return self;
//}
//
//- (id)_viewControllersForRotationCallbacks
//{
//	nppLog(@"%@", [super _viewControllersForRotationCallbacks]);
//	return _navigations;
//}
/*
- (void) viewDidLayoutSubviews
{
	[self setFullScreen:_fullScreen animated:NO];
}

- (void) setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
	[super setNavigationBarHidden:hidden animated:NO];
	[self setFullScreen:_fullScreen animated:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self setFullScreen:_fullScreen animated:NO];
}
//*/
- (void) dealloc
{
	_currentNavigation = nil;
	nppRelease(_navigations);
	nppRelease(_backgroundView);
	
	// *** TabBar
	nppRelease(_tabbars);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end