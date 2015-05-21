/*
 *	NPPPickerView.m
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

#import "NPPPickerView.h"

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
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

static NSArray *_data = nil;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static NPPPickerView *getPickerView(void)
{
	static NPPPickerView *_pickerView = nil;
	
	if (_pickerView == nil)
	{
		// Defines the sizes.
		CGRect bounds = nppDeviceScreenRectOriented(YES);
		CGRect frame = CGRectMake(0.0f, 0.0f, bounds.size.width, 216.0f);
		
		// Creating the toolbal.
		_pickerView = [[NPPPickerView alloc] initWithFrame:frame];
		_pickerView.showsSelectionIndicator = YES;
		_pickerView.dataSource = _pickerView;
		_pickerView.delegate = _pickerView;
		_pickerView.backgroundColor = [UIColor colorWithRed:0.82f green:0.83f blue:0.84f alpha:1.0f];
	}
	
	return _pickerView;
}

@interface NPPPickerView()

@property (nonatomic, NPP_ASSIGN) id <UIPickerViewDelegate> pickerDelegate;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPPickerView

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize pickerDelegate = _pickerDelegate;

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
#pragma mark PickerView and PickerViewDataSource Delegate
/*
- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	GLfloat width = [[[_data objectAtIndex:component] objectForKey:@"Width"] floatValue];
	return (width > 0.0f) ? width : pickerView.width;
}

- (CGFloat) pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	GLfloat height = [[[_data objectAtIndex:component] objectForKey:@"Height"] floatValue];
	return (height > 0.0f) ? height : 40.0f;
}
//*/
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return [_data count];
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [[[_data objectAtIndex:component] objectForKey:@"Values"] count];
}

- (NSString *) pickerView:(UIPickerView *)pickerView
			  titleForRow:(NSInteger)row
			 forComponent:(NSInteger)component
{
	return nppS([[[_data objectAtIndex:component] objectForKey:@"Values"] objectAtIndex:row]);
}

//- (UIView *) pickerView:(UIPickerView *)pickerView
//			 viewForRow:(NSInteger)row
//		   forComponent:(NSInteger)component
//			reusingView:(UIView *)view
//{
//	UIView *finalView = nil;
//	
//	if (_pickerDelegate != nil && [_pickerDelegate respondsToSelector:_cmd])
//	{
//		finalView = [_pickerDelegate pickerView:pickerView
//									 viewForRow:row
//								   forComponent:component
//									reusingView:view];
//	}
//	
//	return finalView;
//}

- (void) pickerView:(UIPickerView *)pickerView
	   didSelectRow:(NSInteger)row
		inComponent:(NSInteger)component
{
	if (_pickerDelegate != nil && [_pickerDelegate respondsToSelector:_cmd])
	{
		[_pickerDelegate pickerView:pickerView didSelectRow:row inComponent:component];
	}
}

#pragma mark -
#pragma mark Self Methods

+ (void) setPickerDelegate:(id <UIPickerViewDelegate>)target
{
	NPPPickerView *pickerView = getPickerView();
	
	pickerView.pickerDelegate = target;
}

+ (void) setDataFromDict:(NSDictionary *)dict sortData:(BOOL)sorting
{
	NSArray *data = [dict objectForKey:@"Items"];
	
	// Clearing old stuffs.
	nppRelease(_data);
	
	//*************************
	//	Plist
	//*************************
	// Sorting the elements by its final string.
	if (sorting)
	{
		NSMutableArray *sorted = [[NSMutableArray alloc] init];
		NSMutableDictionary *newComponent;
		NSDictionary *component;
		NSArray *values;
		
		NSComparator comparison = ^NSComparisonResult(id obj1, id obj2)
		{
			// Gets the localized string to make comparison.
			NSString *name1 = nppS(obj1);
			NSString *name2 = nppS(obj2);
			
			return [name1 compare:name2 options:NSCaseInsensitiveSearch];
		};
		
		// Loop though all sections/components.
		for (component in data)
		{
			newComponent = [[NSMutableDictionary alloc] initWithDictionary:component];
			
			values = [component objectForKey:@"Values"];
			[newComponent setObject:[values sortedArrayUsingComparator:comparison] forKey:@"Values"];
			[sorted addObject:newComponent];
			
			nppRelease(newComponent);
		}
		
		_data = [sorted copy];
		
		nppRelease(sorted);
	}
	else
	{
		_data = [data copy];
	}
	
	//*************************
	//	View Hierarchy
	//*************************
	
	[getPickerView() reloadAllComponents];
}

+ (void) setDataFromFile:(NSString *)fileNamed sortData:(BOOL)sorting
{
	NSString *path = [[NSBundle mainBundle] pathForResource:fileNamed ofType:@"plist"];
	
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	[self setDataFromDict:dict sortData:sorting];
}

+ (NSString *) selectedTextAtColumn:(NSUInteger)column
{
	NPPPickerView *pickerView = getPickerView();
	NSString *text = nil;
	
	// Avoids out of bounds.
	if (column < [pickerView numberOfComponents])
	{
		NSInteger row = [pickerView selectedRowInComponent:column];
		text = nppS([[[_data objectAtIndex:column] objectForKey:@"Values"] objectAtIndex:row]);
	}
	
	return text;
}

+ (NSInteger) selectedRowAtColumn:(NSUInteger)column
{
	NPPPickerView *pickerView = getPickerView();
	NSInteger row = 0;
	
	// Avoids out of bounds.
	if (column < [pickerView numberOfComponents])
	{
		row = [pickerView selectedRowInComponent:column];
	}
	
	return row;
}

+ (void) selectText:(NSString *)text atColumn:(NSUInteger)column
{
	NPPPickerView *pickerView = getPickerView();
	
	NSString *string;
	unsigned int row = 0;
	
	for (string in [[_data objectAtIndex:column] objectForKey:@"Values"])
	{
		if ([nppS(string) isEqualToString:text])
		{
			break;
		}
		
		++row;
	}
	
	[pickerView selectRow:row inComponent:column animated:YES];
}

+ (void) selectRow:(NSUInteger)row atColumn:(NSUInteger)column
{
	NPPPickerView *pickerView = getPickerView();
	
	[pickerView selectRow:row inComponent:column animated:YES];
}

+ (void) showPickerView
{
	NPPPickerView *pickerView = getPickerView();
	NPPWindowKeyboard *window = [NPPWindowKeyboard instance];
	
	[window setHeightWindow:pickerView.height];
	[window addView:pickerView];
	
	pickerView.y = [window heightExtra];
}

+ (void) hidePickerView
{
	NPPPickerView *pickerView = getPickerView();
	NPPWindowKeyboard *window = [NPPWindowKeyboard instance];
	
	[window removeView:pickerView];
}

+ (void) movePickerViewToY:(float)toY
{
	NPPPickerView *pickerView = getPickerView();
	
	[pickerView moveProperty:@"y" to:toY completion:nil];
}

+ (NPPPickerView *) instance
{
	return getPickerView();
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nppRelease(_data);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end


#pragma mark -
#pragma mark Categories
#pragma mark -
//**********************************************************************************************************
//
//	Categories
//
//**********************************************************************************************************

@implementation NPPDataManager (NPPPickerData)

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

+ (NSDictionary *) pickerDataWithArray:(NSArray *)array
{
	NSDictionary *cloumn = [NSDictionary dictionaryWithObject:array forKey:@"Values"];
	NSArray *section = [NSArray arrayWithObject:cloumn];
	NSDictionary *dict = [NSDictionary dictionaryWithObject:section
													 forKey:@"Items"];
	
	return dict;
}

@end