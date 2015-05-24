/*
 *	NPPKeyboardToolbar.m
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

#import "NPPKeyboardToolbar.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_TOOLBAR_HEIGHT				50.0f
#define NPP_BT_MARGIN					3.0f
#define NPP_BT_MARGINX2					6.0f
#define NPP_BT_SIZE						40.0f
#define NPP_BT_SIZE_LARGE				60.0f
#define NPP_KEYBOARD_SHADOW				@"npp_keyboard_shadow.png"
#define NPP_KEYBOARD_BG					@"npp_gray_bg.png"
#define NPP_KEYBOARD_BAR				@"npp_keyboard_bar.png"
								
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
#pragma mark Private Class
//**************************************************
//	Private Class
//**************************************************

// The global keyboard.
@interface NPPToolbar : UIViewController <UITextFieldDelegate, UITextViewDelegate>
{
@private
	int						_editingTag;
	int						_loopingTag;
	int						_lastTag;
	BOOL					_hasSuperReference;
	BOOL					_showing;
	UIEdgeInsets			_superEdges;
	NSMutableArray			*_items;
}

// Delegate target.
@property (nonatomic, NPP_ASSIGN) id <NPPKeyboardDelegate> delegateKeyboard;

// Items to interact between keyboard navigation.
@property (nonatomic, readonly) NSMutableArray *items;

// Retrieves the current view.
@property (nonatomic, readonly) UIView *currentItem;

// Retrieves the current view.
@property (nonatomic, NPP_RETAIN) UIView *contentView;

// Retrieves the holder view, the view containing all contentView and the background.
@property (nonatomic, NPP_RETAIN) UIView *holderView;

@property (nonatomic) BOOL autoMoveScrollView;
@property (nonatomic, readonly) int lastTag;
@property (nonatomic, getter = isShowing) BOOL showing;

// Keyboard actions.
- (void) toolbarDone:(id)sender;
- (void) toolbarNavigate:(id)sender;

// Changing current editing view.
- (BOOL) shouldEditTag:(int)tag action:(NPPKeyboardAction)action;

@end

//*************************
//	Private Category
//*************************

@interface NPPToolbar()

// Initializes a new instance.
- (void) initializing;

- (void) keyboardWillChange:(NSNotification *)notification;
- (void) keyboardDidChange:(NSNotification *)notification;
- (void) adjustViewToKeyboard:(UIView *)view goingOut:(BOOL)goingOut;

@end

//*************************
//	Implementation
//*************************

@implementation NPPToolbar

//*************************
//	Properties
//*************************

@synthesize delegateKeyboard = _delegateKeyboard, items = _items, currentItem = _currentItem,
			contentView = _contentView, holderView = _holderView,
			autoMoveScrollView = _autoMoveScrollView, lastTag = _lastTag;

@dynamic showing;

- (BOOL) isShowing { return _showing; }
- (void) setShowing:(BOOL)value
{
	NPPWindowKeyboard *window = [NPPWindowKeyboard instance];
	
	_showing = value;
	
	if (_showing)
	{
		[window setHeightExtra:_contentView.height];
		[window addView:self.view atIndex:0];
		[window showAnimated:YES completion:nil];
	}
	else
	{
		[window removeView:self.view];
		[window hideAnimated:YES completion:nil];
	}
}

//*************************
//	Constructors
//*************************

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

//*************************
//	Private Methods
//*************************

- (void) initializing
{
	// Default settings.
	_autoMoveScrollView = YES;
	_items = [[NSMutableArray alloc] init];
	
	// Setting the default valid frame.
	CGRect _validFrame = [[NPPWindowKeyboard instance] frameFull];
	
	// Creating the layout.
	UIImage *bg = nppImageFromFile(NPP_KEYBOARD_BG);
	UIImage *bar = nppImageFromFile(NPP_KEYBOARD_BAR);
	UIImageView *bgView = [[UIImageView alloc] initWithImage:bg];
	UIImageView *barView = [[UIImageView alloc] initWithImage:bar];
	bgView.contentMode = UIViewContentModeScaleToFill;
	barView.contentMode = UIViewContentModeScaleToFill;
	bgView.width = _validFrame.size.width;
	barView.width = _validFrame.size.width;
	
	// Layout constraits.
	UIView *contentView = [[UIView alloc] initWithFrame:barView.frame];
	UIView *holderView = [[UIView alloc] initWithFrame:_validFrame];
	UIView *view = [[UIView alloc] initWithFrame:_validFrame];
	[holderView addSubview:bgView];
	[holderView addSubview:barView];
	[holderView addSubview:contentView];
	[view addSubview:holderView];
	
	bgView.autoresizingMask = NPPAutoresizingSizes;
	barView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	view.autoresizingMask = NPPAutoresizingSizes;
	
	contentView.height = NPP_TOOLBAR_HEIGHT;
	holderView.clipsToBounds = YES;
	
	// Retaining the instances.
	self.view = view;
	self.contentView = contentView;
	self.holderView = holderView;
	
	// If there was a wait to keep monitoring the undocked keyboard movement,
	// this GLUE CODE would not be necessary.
	
	// GLUE CODE.
	// Re-add the holderView to the original place after changing the keyboard,
	// because before hidding, the keyboard send a message "removeFromSuperView", which will conflict
	// with the original holderView's place. "DidChange" is used because "DidHide" is not called when
	// dismissing an undocked keyboard on iOS 5 or later.
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	SEL selector = Nil;
	
	//UIDeviceOrientationDidChangeNotification
	//UIApplicationDidChangeStatusBarOrientationNotification
	selector = @selector(keyboardWillChange:);
	[center addObserver:self selector:selector name:UIKeyboardWillChangeFrameNotification object:nil];
	
	selector = @selector(keyboardDidChange:);
	[center addObserver:self selector:selector name:UIKeyboardDidChangeFrameNotification object:nil];
	
	nppRelease(bgView);
	nppRelease(barView);
	nppRelease(contentView);
	nppRelease(holderView);
	nppRelease(view);
}

- (void) keyboardWillChange:(NSNotification *)notification
{
	[self adjustViewToKeyboard:_currentItem goingOut:NO];
}

- (void) keyboardDidChange:(NSNotification *)notification
{
	if (![_currentItem respondsToSelector:@selector(setInputAccessoryView:)] && _currentItem != nil)
	{
		CGRect _validFrame = [[NPPWindowKeyboard instance] frameFull];
		_holderView.height = _validFrame.size.height;
		_holderView.autoresizingMask = NPPAutoresizingSizes;
		[self.view addSubview:_holderView];
	}
}

- (void) adjustViewToKeyboard:(UIView *)view goingOut:(BOOL)goingOut
{
	// Moving the scroll view, if the candidate view is inside a scroll view in any form.
	Class scrollClass = [UIScrollView class];
	UIScrollView *superView = (UIScrollView *)[view superview];
	CGRect superFrame = CGRectZero;
	
	// Loop in hierarchy until find a scroll view class, if no one is found, it'll be nil in the end.
	while (superView != nil && ![superView isKindOfClass:scrollClass])
	{
		superView = (UIScrollView *)[superView superview];
	}
	
	superFrame = [superView frame];
	
	// Just proceeds with a scroll view, for sure.
	if (superView != nil && _autoMoveScrollView)
	{
		if (!_hasSuperReference)
		{
			// Storing a reference to the original frame and setting the content size if needed.
			_hasSuperReference = YES;
			_superEdges = UIEdgeInsetsZero;
			_superEdges.top = superFrame.origin.y;
			_superEdges.bottom = superView.superview.height - (_superEdges.top + superFrame.size.height);
			
			if (CGSizeEqualToSize([superView contentSize], CGSizeZero))
			{
				[superView setContentSize:superFrame.size];
			}
		}
		
		// Getting the parents views, including window and calculating the final Y and Height.
		UIWindow *window = superView.window;
		CGRect rect = [window convertRect:superFrame toWindow:window];
		CGRect frameInWindow = [superView convertRect:window.frame fromView:window];
		
		//TODO this is not calculating the status bar size, that means it's not working properly on iOS 6.
		// Calculating the sizes.
		float keyboardHeight = _holderView.height + [[NPPWindowKeyboard instance] heightWindow];
		float toHeight = frameInWindow.size.height - keyboardHeight;
		float toY = 0.0f;
		
		// When it's going out, everything will back to the normal.
		if (goingOut)
		{
			toY = _superEdges.top;
			toHeight = superView.superview.height - (toY + _superEdges.bottom);
			_hasSuperReference = NO;
		}
		else
		{
			toY = superFrame.origin.y - rect.origin.y;
		}
		
		// Moving and resizing the scroll view when it's changing the states.
		if (goingOut || superFrame.origin.y != toY || superFrame.size.height != toHeight)
		{
			[superView moveProperty:@"y" to:toY completion:nil];
			if (![superView isKindOfClass:[UITableView class]])
			{
				[superView moveProperty:@"height" to:toHeight completion:nil];
			}
		}
		
		// Scroll offset.
		CGPoint point = [view convertPoint:CGPointZero toView:superView];
		float topInset = [superView contentInset].top;
		float offsetY = point.y - (toHeight * 0.5f);
		offsetY = (offsetY < -topInset) ? -topInset : offsetY;
		[superView setContentOffset:CGPointMake(0, offsetY) animated:YES];
	}
}

//*************************
//	Self Public Methods
//*************************

//*************************
//	UITextFieldDelegate
//*************************

- (BOOL) textFieldShouldBeginEditing:(UITextField *)item
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textFieldDidChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:item];
	
	[NPPKeyboardToolbar setCurrentItem:item];
	return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)item
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UITextFieldTextDidChangeNotification
												  object:nil];
	
	[self toolbarDone:nil];
	return NO;
}

- (BOOL) textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
 replacementString:(NSString *)string
{
	BOOL toReturn = YES;
	
	// Delegate methods.
	if ([_delegateKeyboard respondsToSelector:@selector(keyboardShouldChange:string:inRange:)])
	{
		toReturn = [_delegateKeyboard keyboardShouldChange:textField string:string inRange:range];
	}
	
	/*
	// Treating all the text changes.
	if (toReturn)
	{
		NSString *text = [textField.text stringByReplacingCharactersInRange:range
																 withString:string];
		
		// Special text treatment like, capitalization, email, upper case, lower case, etc.
		if (textField.autocapitalizationType == UITextAutocapitalizationTypeAllCharacters)
		{
			text = [text uppercaseString];
		}
		else if (textField.keyboardType == UIKeyboardTypeEmailAddress)
		{
			text = [text lowercaseString];
		}
		
		// Change the text manually and avoid doing it automatically.
		// Here is a little trick to avoid using NSNotificationCenter to track the text changes.
		// Using the notification system can be very expensive and requires unregistring contantly.
		textField.text = text;
		toReturn = NO;
		
		// Calls the "did change" method directly.
		if ([_delegateKeyboard respondsToSelector:@selector(keyboardDidChange:)])
		{
			[_delegateKeyboard keyboardDidChange:textField];
		}
	}
	//*/

	return toReturn;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
//	NSRange range = NSMakeRange(0, textField.text.length);
//	[self textField:textField shouldChangeCharactersInRange:range replacementString:@""];
	return YES;
}

- (void) textFieldDidChange:(NSNotification *)notification
{
	UITextField *item = (UITextField *)notification.object;
	
	// Special text treatment like, capitalization, email, upper case, lower case, etc.
	if (item.autocapitalizationType == UITextAutocapitalizationTypeAllCharacters)
	{
		UITextRange *caret = item.selectedTextRange;
		item.text = [[item text] uppercaseString];
		[item setSelectedTextRange:caret];
	}
	else if (item.keyboardType == UIKeyboardTypeEmailAddress)
	{
		UITextRange *caret = item.selectedTextRange;
		item.text = [[item text] lowercaseString];
		[item setSelectedTextRange:caret];
	}
	
	// Calls the "did change" method directly.
	if ([_delegateKeyboard respondsToSelector:@selector(keyboardDidChange:)])
	{
		[_delegateKeyboard keyboardDidChange:item];
	}
}

//*************************
//	UITextViewDelegate
//*************************

- (BOOL) textViewShouldBeginEditing:(UITextView *)item
{
	[NPPKeyboardToolbar setCurrentItem:item];
	return YES;
}

- (BOOL) textViewShouldEndEditing:(UITextView *)item
{
	[self toolbarDone:nil];
	return YES;
}

- (BOOL) textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
  replacementText:(NSString *)string
{
	BOOL toReturn = YES;
	
	// Delegate methods.
	if ([_delegateKeyboard respondsToSelector:@selector(keyboardShouldChange:string:inRange:)])
	{
		toReturn = [_delegateKeyboard keyboardShouldChange:textView string:string inRange:range];
	}
	
	return toReturn;
}
//*
- (void) textViewDidChange:(UITextView *)item
{
	// Special text treatment like, capitalization, email, upper case, lower case, etc.
	if (item.autocapitalizationType == UITextAutocapitalizationTypeAllCharacters)
	{
		UITextRange *caret = item.selectedTextRange;
		item.text = [[item text] uppercaseString];
		[item setSelectedTextRange:caret];
	}
	else if (item.keyboardType == UIKeyboardTypeEmailAddress)
	{
		UITextRange *caret = item.selectedTextRange;
		item.text = [[item text] lowercaseString];
		[item setSelectedTextRange:caret];
	}
	
	// Calls the "did change" method directly.
	if ([_delegateKeyboard respondsToSelector:@selector(keyboardDidChange:)])
	{
		[_delegateKeyboard keyboardDidChange:item];
	}
}
//*/
//*************************
//	Self Methods
//*************************

- (void) toolbarDone:(id)sender
{
	// Delegate methods.
	if ([_delegateKeyboard respondsToSelector:@selector(keyboardDoneAction)])
	{
		[_delegateKeyboard keyboardDoneAction];
	}
}

- (void) toolbarNavigate:(id)sender
{
	NPPKeyboardAction action = (int)[(NPPButton *)sender tag];
	
	int editingTag = 0;
	int count = (int)[_items count];
	
	// Defining the direction of the navigation.
	switch(action)
	{
			// Previous
		case NPPKeyboardActionPrevious:
			editingTag = _loopingTag - 1;
			break;
			// Next
		case NPPKeyboardActionNext:
			editingTag = _loopingTag + 1;
			break;
		default:
			break;
	}
	
	// Adjust the tag to loop through the form.
	editingTag = (editingTag > count) ? 1 : (editingTag < 1) ? count : editingTag;
	
	// Set the new item.
	if (![self shouldEditTag:editingTag action:action])
	{
		[self toolbarNavigate:sender];
	}
}

- (BOOL) shouldEditTag:(int)tag action:(NPPKeyboardAction)action
{
	if (tag == _editingTag)
	{
		return YES;
	}
	
	UIView *item = Nil;
	
	// Delegate methods.
	if (tag > 0)
	{
		item = ([_items count] >= tag) ? [_items objectAtIndex:tag - 1] : nil;
		
		//???
		//_loopingTag != _editingTag
		
		// Checking if the next item is enabled.
		if ([item respondsToSelector:@selector(isEnabled)] && ![(id)item isEnabled])
		{
			_loopingTag = tag;
			return NO;
		}
		
		// Checking with the delegate if the navigation can occurs on the next target.
		if ([_delegateKeyboard respondsToSelector:@selector(keyboardShouldNavigateTo:onAction:)] &&
			![_delegateKeyboard keyboardShouldNavigateTo:item onAction:action])
		{
			_loopingTag = tag;
			return NO;
		}
	}
	
	// The last tag keeps tracking the last valid tag.
	_lastTag = (_editingTag != _lastTag) ? _editingTag : _lastTag;
	tag = NPPClamp(tag, 0, (unsigned int)[_items count]);
	
	// Updating the new tags.
	BOOL isIn = (_editingTag == 0);
	BOOL isOut = (tag == 0);
	_editingTag = tag;
	_loopingTag = tag;
	
	// Decrements the current tag, transforming it into the index.
	tag = MAX(0, tag - 1);
	item = ([_items count] > 0) ? [_items objectAtIndex:tag] : nil;
	
	// Navigating though the items.
	if (!isOut)
	{
		// Removes the last inputAccessoryView, if necessary.
		if ([_currentItem respondsToSelector:@selector(setInputAccessoryView:)])
		{
			[(id)_currentItem setInputAccessoryView:nil];
		}
		
		// Just change the where the holderView is placed.
		// There are in keyboard input classes an accessory view that is bound to the keyboard.
		// Using this property is better, since the keyboard on iPad can be moved arbitrary by the user.
		if ([item respondsToSelector:@selector(setInputAccessoryView:)])
		{
			_holderView.height = _contentView.height;
			_holderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			[(id)item setInputAccessoryView:_holderView];
		}
		// If the current item is not a keyboard input,
		// then move back the holderView to its original place.
		else
		{
			CGRect _validFrame = [[NPPWindowKeyboard instance] frameFull];
			_holderView.height = _validFrame.size.height;
			_holderView.autoresizingMask = NPPAutoresizingSizes;
			[self.view addSubview:_holderView];
		}
		
		_currentItem = item;
	}
	else
	{
		_currentItem = nil;
	}
	
	// Doesn't change the first responder when the user is starting the edit mode.
	if (nppDeviceOSVersion() >= 6.0f)
	{
		[[UIView findFirstResponder] resignFirstResponder];
		[_currentItem becomeFirstResponder];
	}
	else if (!isIn)
	{
		[[UIView findFirstResponder] resignFirstResponder];
		[_currentItem becomeFirstResponder];
	}
	
	// Animating and adjusting the scroll view.
	[self adjustViewToKeyboard:item goingOut:isOut];
	
	if (isIn)
	{
		[NPPKeyboardToolbar showToolbar];
	}
	else if (isOut)
	{
		[NPPKeyboardToolbar hideToolbar];
	}
	
	return YES;
}

//*************************
//	Override Public Methods
//*************************

- (BOOL) shouldAutorotate
{
	return NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return NO;
}

- (void) dealloc
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self];
	
	nppRelease(_items);
	nppRelease(_contentView);
	nppRelease(_holderView);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

NPP_STATIC_READONLY(NPPToolbar, getToolbar);

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPKeyboardToolbar

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark Navigation
//*************************
//	Navigation
//*************************

+ (void) setItemsWithArray:(NSArray *)array
{
	NPPToolbar *toolBar = getToolbar();
	NSMutableArray *items = [toolBar items];
	UIView * item;
	
	[items removeAllObjects];
	
	// Loops through all elements.
	for (item in array)
	{
		[items addObject:item];
		
		if ([item isKindOfClass:[UITextField class]])
		{
			[(UITextField *)item setDelegate:toolBar];
		}
		else if ([item isKindOfClass:[UITextView class]])
		{
			[(UITextView *)item setDelegate:toolBar];
		}
	}
}

+ (void) setItems:(UIView *)first, ...
{
	NSMutableArray *items = [NSMutableArray array];
	UIView * item = nil;
	va_list list;
	
	// Executes the list to work with all elements until get nil.
	va_start(list, first);
	for (item = first; item != nil; item = va_arg(list, UIView *))
	{
		[items addObject:item];
	}
	va_end(list);
	
	[self setItemsWithArray:items];
}

+ (UIView *) currentItem { return [getToolbar() currentItem]; }
+ (void) setCurrentItem:(UIView *)item
{
	NPPToolbar *toolBar = getToolbar();
	
	// Sets the current editing tag.
	[toolBar shouldEditTag:(item != nil) ? (unsigned int)[toolBar.items indexOfObject:item] + 1 : 0
					action:NPPKeyboardActionSet];
}

+ (void) restoreLastItem
{
	NPPToolbar *toolBar = getToolbar();
	
	// Sets the current editing tag.
	[toolBar shouldEditTag:toolBar.lastTag action:NPPKeyboardActionSet];
}

+ (void) resetAll
{
	[NPPKeyboardToolbar setCurrentItem:nil];
	
	NPPToolbar *toolBar = getToolbar();
	NSMutableArray *items = [toolBar items];
	UIView * item = nil;
	
	// Loops through all elements removing textfield delegates.
	for (item in items)
	{
		if ([item isKindOfClass:[UITextField class]])
		{
			[(UITextField *)item setDelegate:nil];
		}
	}
	
	toolBar.delegateKeyboard = nil;
	[toolBar shouldEditTag:0 action:NPPKeyboardActionSet];
	[items removeAllObjects];
}

+ (NSArray *) allItems
{
	NPPToolbar *toolBar = getToolbar();
	
	return [NSArray arrayWithArray:[toolBar items]];
}

+ (void) setButtons:(UIButton *)first, ...
{
	NPPToolbar *toolBar = getToolbar();
	UIButton *item = nil;
	va_list list;
	float posX = NPP_BT_MARGIN;
	
	CGRect frame = toolBar.contentView.frame;
	frame.origin = CGPointMake(NPP_BT_MARGIN, 0.0f);
	frame.size.width *= 0.7f;
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
	scrollView.showsHorizontalScrollIndicator = NO;
	[toolBar.contentView addSubview:scrollView];
	
	// Executes the list to work with all elements until get nil.
	va_start(list, first);
	for (item = first; item != nil; item = va_arg(list, UIButton *))
	{
		[item centerYInView:scrollView];
		item.x = posX;
		
		[scrollView addSubview:item];
		
		posX += item.width + NPP_BT_MARGIN * 0.2f;
	}
	va_end(list);
	
	// If the size of buttons exceed the scroll view width, prepare it to the scrolling behavior.
	if (posX > frame.size.width)
	{
		UIImage *shadowImage = nppImageFromFile(NPP_KEYBOARD_SHADOW);
		UIImageView *leftImage = [[UIImageView alloc] initWithImage:shadowImage];
		UIImageView *rightImage = [[UIImageView alloc] initWithImage:[shadowImage imageRotatedBy:180.0f]];
		leftImage.x = scrollView.x;
		rightImage.x = scrollView.x + scrollView.width - rightImage.width;
		[leftImage centerYInView:scrollView];
		[rightImage centerYInView:scrollView];
		[toolBar.contentView addSubview:leftImage];
		[toolBar.contentView addSubview:rightImage];
		
		scrollView.contentSize = CGSizeMake(posX + NPP_BT_MARGIN, frame.size.height);
		nppRelease(leftImage);
		nppRelease(rightImage);
	}
	
	nppRelease(scrollView);
}

+ (void) setNavigationWithTarget:(id <NPPKeyboardDelegate>)target
				   arrowsButtons:(BOOL)arrows
					  doneButton:(BOOL)done
{
	NPPToolbar *toolBar = getToolbar();
	NPPButton *btLeft, *btRight, *btDone;
	NPPStyleColor style = NPPStyleColorLight;
	UIFont *font = [UIFont fontWithName:@"Helvetica" size:18.0];
	NSString *title = nil;
	CGRect frame = CGRectZero;
	CGSize size;
	
	toolBar.delegateKeyboard = target;
	[[toolBar contentView] removeAllSubviews];
	
	SEL actionNavigate = @selector(toolbarNavigate:);
	SEL actionDone = @selector(toolbarDone:);
	
	// Arrow buttons.
	if ([[toolBar items] count] > 1)
	{
		title = nppS(@"<");
		size = [title sizeWithFont:font
						   minSize:font.pointSize
						  forWidth:200.0f
						 lineBreak:0];
		
		frame = CGRectMake(NPP_BT_MARGIN, 0.0f, NPP_BT_SIZE, NPP_BT_SIZE);
		frame.size.width = MAX(size.width + NPP_BT_MARGINX2, NPP_BT_SIZE + NPP_BT_MARGINX2);
		btLeft = [NPPButton buttonWithTitle:title image:nil type:NPPButtonTypeKeyLeft style:style];
		[btLeft addTarget:toolBar action:actionNavigate forControlEvents:UIControlEventTouchUpInside];
		btLeft.titleLabel.font = font;
		btLeft.tag = NPPKeyboardActionPrevious;
		btLeft.frame = frame;
		btLeft.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[btLeft centerYInView:toolBar.contentView];
		btLeft.hidden = !arrows;
		
		title = nppS(@">");
		size = [title sizeWithFont:font
						   minSize:font.pointSize
						  forWidth:200.0f
						 lineBreak:0];
		
		frame = CGRectMake(btLeft.x + btLeft.width, 0.0f, NPP_BT_SIZE, NPP_BT_SIZE);
		frame.size.width = MAX(size.width + NPP_BT_MARGINX2, NPP_BT_SIZE + NPP_BT_MARGINX2);
		btRight = [NPPButton buttonWithTitle:title image:nil type:NPPButtonTypeKeyRight style:style];
		[btRight addTarget:toolBar action:actionNavigate forControlEvents:UIControlEventTouchUpInside];
		btRight.titleLabel.font = font;
		btRight.tag = NPPKeyboardActionNext;
		btRight.frame = frame;
		btLeft.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[btRight centerYInView:toolBar.contentView];
		btRight.hidden = !arrows;
		
		[toolBar.contentView addSubview:btLeft];
		[toolBar.contentView addSubview:btRight];
	}
	
	// Done button.
	title = nppS(@"LB_OK");
	size = [title sizeWithFont:font
					   minSize:font.pointSize
					  forWidth:200.0f
					 lineBreak:0];
	
	frame.size.width = MAX(size.width + NPP_BT_MARGINX2, NPP_BT_SIZE_LARGE);
	frame.size.height = NPP_BT_SIZE;
	frame.origin.y = 0.0f;
	frame.origin.x = toolBar.view.width - frame.size.width - NPP_BT_MARGIN;
	btDone = [NPPButton buttonWithTitle:title image:nil type:NPPButtonTypeKey style:style];
	[btDone addTarget:toolBar action:actionDone forControlEvents:UIControlEventTouchUpInside];
	btDone.titleLabel.font = font;
	btDone.tag = NPPKeyboardActionSet;
	btDone.frame = frame;
	btDone.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	[btDone centerYInView:toolBar.contentView];
	btDone.hidden = !done;
	
	[toolBar.contentView addSubview:btDone];
	[self setHiddenButtons:(!arrows && !done)];
}

+ (void) setDoneButtonTitle:(NSString *)title highlighted:(BOOL)isBlue
{
	NPPToolbar *toolBar = getToolbar();
	NPPButton *btDone = (NPPButton *)[[toolBar contentView] viewWithTag:NPPKeyboardActionSet];
	
	if ([btDone isKindOfClass:[NPPButton class]])
	{
		if (title.length > 0)
		{
			UIFont *font = btDone.titleLabel.font;
			CGSize size = [title sizeWithFont:font
									  minSize:font.pointSize
									 forWidth:200.0f
									lineBreak:0];
			
			btDone.width = MAX(size.width + (NPP_BT_MARGIN * 2.0f), NPP_BT_SIZE_LARGE);
			btDone.x = toolBar.view.width - btDone.width - NPP_BT_MARGIN;
			[btDone setTitle:title forState:UIControlStateNormal];
			[btDone setType:NPPButtonTypeKey andStyle:(isBlue) ? NPPStyleColorConfirm : NPPStyleColorLight];
			btDone.hidden = NO;
			[self setHiddenButtons:NO];
		}
		else
		{
			btDone.hidden = YES;
			[self setHiddenButtons:YES];
		}
	}
}

+ (void) setHiddenButtons:(BOOL)isHidden
{
	NPPToolbar *toolBar = getToolbar();
	
	toolBar.contentView.height = (isHidden) ? 0.0f : NPP_TOOLBAR_HEIGHT;
}

#pragma mark -
#pragma mark Animation
//*************************
//	Animation
//*************************

+ (void) showToolbar
{
	NPPToolbar *toolBar = getToolbar();
	
	toolBar.showing = YES;
	
	// Delegate methods.
	if ([toolBar.delegateKeyboard respondsToSelector:@selector(keyboardWillShow)])
	{
		[toolBar.delegateKeyboard keyboardWillShow];
	}
}

+ (void) hideToolbar
{
	NPPToolbar *toolBar = getToolbar();
	
	toolBar.showing = NO;
	
	// Delegate methods.
	if ([toolBar.delegateKeyboard respondsToSelector:@selector(keyboardWillHide)])
	{
		[toolBar.delegateKeyboard keyboardWillHide];
	}
}

+ (void) setAutoMoveScrollView:(BOOL)enabled
{
	NPPToolbar *toolBar = getToolbar();
	[toolBar setAutoMoveScrollView:enabled];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end
