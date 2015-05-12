/*
 *	NPPTableViewController.m
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

#import "NPPTableViewController.h"

#import "NPPTableViewCell.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kNPPDefaultCellClass	@"NPPTableViewCell"
#define kNPPWarningCellClass	@"WARNING: The %@ is not a valid class."

#define NPP_STR_NIB				@".nib"

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

NPP_ARC_RETAIN static NSString *_cellClass = nil;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static float nppGetTableViewItemHeight(NSDictionary *data)
{
	float height = 0.0f;
	
	// Taking the class from the provided data.
	NSString *classString = [data objectForKey:kNPPTableClass];
	if (classString != nil)
	{
		UIView *item = nil;
		Class classObject = NSClassFromString(classString);
		
		// Tries to find a XIB for that class, if not found, tries to get the height directly.
		if ((item = nppItemFromXIB(classString)))
		{
			height = [item height];
		}
		else if ([classObject respondsToSelector:@selector(heightForItem)])
		{
			height = [classObject heightForItem];
		}
	}
	
	return height;
}

static UIView *nppGetTableViewItem(NSDictionary *data, NSString *baseClass)
{
	UIView *cell = nil;
	
	// Taking the base class, if it's nil, takes the class from the provided data.
	NSString *classString = (baseClass != nil) ? baseClass : [data objectForKey:kNPPTableClass];
	if (classString != nil)
	{
		Class classObject = NSClassFromString(classString);
		if (classObject == nil)
		{
			// Sets the default cell.
			nppLog(kNPPWarningCellClass, classString);
			classObject = NSClassFromString(_cellClass);
		}
		
		// Tries to find a XIB file for that class, if not found, create a new instance.
		if (!(cell = nppItemFromXIB(classString)))
		{
			cell = nppAutorelease([[classObject alloc] init]);
		}
	}
	
	return cell;
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPTableViewController()

// Initializes a new instance.
- (void) initializing;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPTableViewController

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize tableView = _tableView, selectedIndexPath = _selectedIndexPath,
			selectedIndexPaths = _selectedIndexPaths;

@dynamic delegate, scrollDelegate, data;

- (id) delegate { return _delegate; }
- (void) setDelegate:(id)value
{
	_delegate = (value != nil) ? value : self;
}

- (id <UIScrollViewDelegate>) scrollDelegate { return _scrollDelegate; }
- (void) setScrollDelegate:(id<UIScrollViewDelegate>)value
{
	_scrollDelegate = value;
}

- (NSDictionary *) data { return _data; }
- (void) setData:(NSDictionary *)value
{
	[self.view removeAllSubviews];
	
	//*************************
	//	Plist
	//*************************
	NSDictionary *aSection;
	NSMutableArray *cellsData;
	NSMutableDictionary *sectionData;
	NSMutableArray *newSections = [NSMutableArray array];
	
	// New cell data.
	nppRelease(_dataState);
	_dataState = [[NSMutableDictionary alloc] init];
	
	// Making mutable copies of the plist data.
	nppRelease(_data);
	_data = [[NSMutableDictionary alloc] initWithDictionary:value];
	
	// Mutable copies for sections and data.
	for (aSection in [value objectForKey:kNPPTableSections])
	{
		sectionData = [NSMutableDictionary dictionaryWithDictionary:aSection];
		cellsData = [NSMutableArray arrayWithArray:[aSection objectForKey:kNPPTableCells]];
		
		[sectionData setObject:cellsData forKey:kNPPTableCells];
		
		[newSections addObject:sectionData];
	}
	
	// Updating the section data with the mutable source.
	[_data setObject:newSections forKey:kNPPTableSections];
	
	// Avoids empty source.
	if ([_data count] == 0)
	{
		return;
	}
	
	// Default gestures.
	_gestures = NPPGestureNone;
	_gestures = ([_data objectForKey:kNPPTableGestureSwipe]) ? _gestures | NPPGestureSwipe : _gestures;
	_gestures = ([_data objectForKey:kNPPTableGesturePress]) ? _gestures | NPPGestureLongPress : _gestures;
	
	//*************************
	//	View Hierarchy
	//*************************
	// Default table size.
	CGRect frame = self.view.bounds;
	UITableView *table = nil;
	
	// Table.
	if (![_customView isKindOfClass:[UITableView class]])
	{
		// Background image.
		UIImage *image = [UIImage imageNamed:[_data objectForKey:kNPPTableBackground]];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		UITableViewStyle style = [[_data objectForKey:kNPPTableStyle] intValue];
		
		table = [[UITableView alloc] initWithFrame:frame style:style];
		table.delegate = self;
		table.dataSource = self;
		table.bounces = [[_data objectForKey:kNPPTableBounces] boolValue];
		table.opaque = NO;
		table.backgroundColor = nil;
		table.backgroundView = imageView;
		table.separatorStyle = [[_data objectForKey:kNPPTableSeparatorStyle] intValue];
		
		_customView = table;
		self.view = _customView;
		
		nppRelease(imageView);
	}
	else
	{
		table = (UITableView *)nppRetain(_customView);
		table.delegate = self;
		table.dataSource = self;
		
		//TODO find a better way to clean up the cached cells.
		//[table setValue:nil forKey:@"_reusableTableCells"];
		
		[table reloadData];
	}
	
	// Retains the table for external reference.
	self.tableView = table;
	
	// Releases the memory.
	nppRelease(table);
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

- (id) initWithView:(UIView *)aView file:(NSString *)plist target:(id)delegate
{
	if ((self = [super initWithNibName:nil bundle:nil]))
	{
		[self initializing];
		
		// Doesn't need to retain, because they are just reference.
		// The view will be retained by the "view" property.
		_customView = aView;
		_delegate = delegate;
		
		self.view = (![_customView isKindOfClass:[UITableView class]]) ? _customView : nil;
		self.data = [NSDictionary dictionaryWithContentsOfFile:nppMakePath(plist)];
	}
	
	return self;
}

- (id) initWithView:(UIView *)aView data:(NSDictionary *)dictionary target:(id)delegate
{
	if ((self = [super initWithNibName:nil bundle:nil]))
	{
		[self initializing];
		
		// Doesn't need to retain, because they are just reference.
		// The view will be retained by the "view" property.
		_customView = aView;
		_delegate = delegate;
		
		self.view = (![_customView isKindOfClass:[UITableView class]]) ? _customView : nil;
		self.data = dictionary;
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
	// Initializing.
	_selectedIndexPaths = [[NSMutableArray alloc] init];
	
	if (_cellClass == NULL)
	{
		[[self class] defineCellClassName:kNPPDefaultCellClass];
	}
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark Self Methods
//*************************
//	Self Methods
//*************************

- (void) tableGesture:(NPPGesture)gesture willStartAtIndexPath:(NSIndexPath *)path
{
	_lockSelection = YES;
	
	NSString *gestureName = nil;
	
	switch (gesture)
	{
		case NPPGestureSwipe:
			gestureName = kNPPTableGestureSwipe;
			break;
		case NPPGestureLongPress:
			gestureName = kNPPTableGesturePress;
			break;
		default:
			break;
	}
	
	// Avoid unrecognized touches or cells.
	if (gestureName == nil || path == nil)
	{
		return;
	}
	
	// Preparing the callback method.
	// Local settings override the global ones.
	NSDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:path.section];
	NSDictionary *cellData = [[sectionData objectForKey:kNPPTableCells] objectAtIndex:path.row];
	NSString *selectorName = [cellData objectForKey:gestureName];
	selectorName = (selectorName != nil) ? selectorName : [_data objectForKey:gestureName];
	
	// Can select the cell.
	if (selectorName != nil)
	{
		// Sets the selected cell.
		self.selectedIndexPath = path;
		nppPerformAction(_delegate, NSSelectorFromString(selectorName));
	}
	// Can't select the cell.
	else
	{
		self.selectedIndexPath = nil;
	}
}

- (void) tableGesture:(NPPGesture)gesture didEndAtIndexPath:(NSIndexPath *)indexPath
{
	// Prevents cell selection for a while.
	double delayInSeconds = 0.3f;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
	{
		_lockSelection = NO;
	});
}
/*
- (void) insertRow:(NSInteger)row inSection:(NSInteger)section completion:(NPPBlockVoid)block
{
	// Updates the table data.
	NSMutableDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:section];
	NSMutableArray *cellsData = [sectionData objectForKey:kNPPTableCells];
	[cellsData insertObject:[NSMutableDictionary dictionary] atIndex:row];
	
	NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]];
	[_tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
	
	nppBlockAfter(0.35f, block);
}

- (void) deleteRow:(NSInteger)row inSection:(NSInteger)section completion:(NPPBlockVoid)block
{
	// Updates the table data.
	NSMutableDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:section];
	NSMutableArray *cellsData = [sectionData objectForKey:kNPPTableCells];
	[cellsData removeObjectAtIndex:row];
	
	NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]];
	[_tableView deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
	
	nppBlockAfter(0.35f, block);
}

- (void) deleteSection:(NSInteger)section completion:(NPPBlockVoid)block
{
	// Updates the table data.
	NSMutableArray *sections = [_data objectForKey:kNPPTableSections];
	if (section < [sections count])
	{
		[sections removeObjectAtIndex:section];
		
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
		[_tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
		
		nppBlockAfter(0.35f, block);
	}
}
//*/
- (void) updateCellValue:(id)object key:(NSString *)key forRow:(NSInteger)row inSection:(NSInteger)section
{	
	// Updates the table data.
	NSMutableDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:section];
	NSMutableDictionary *data = [[[sectionData objectForKey:kNPPTableCells] objectAtIndex:row] mutableCopy];
	NSMutableDictionary *properties = [data objectForKey:kNPPTableProperties];
	properties = (properties != nil) ? properties : [_data objectForKey:kNPPTableCellProperties];
	properties = [properties mutableCopy];
	
	// Updates the cell.
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
	NPPTableViewCell *cell = (NPPTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
	float oldHeight = cell.cellHeight;
	[cell setValue:object forKey:key];
	
	if (object == nil)
	{
		[properties removeObjectForKey:key];
	}
	else
	{
		[properties setObject:object forKey:key];
	}
	
	// Updates the cell height. When the updateTable is called, it'll use the new height.
	if ((cell.cellHeight != oldHeight))
	{
		[data setObject:[NSNumber numberWithFloat:cell.cellHeight] forKey:kNPPTableHeight];
	}
	
	// Updates the cell data.
	[data setObject:properties forKey:kNPPTableProperties];
	
	[[sectionData objectForKey:kNPPTableCells] replaceObjectAtIndex:row withObject:data];
	
	nppRelease(data);
	nppRelease(properties);
}

- (void) updateCellData:(NSDictionary *)cellData forRow:(NSInteger)row inSection:(NSInteger)section
{
	// Updates the table data.
	NSMutableDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:section];
	NSMutableArray *cellsData = [sectionData objectForKey:kNPPTableCells];
	NSMutableDictionary *cellCopy = [cellData mutableCopy];
	
	if (cellCopy == nil)
	{
		[cellsData removeObjectAtIndex:row];
		[_tableView reloadData];
	}
	else
	{
		// Updates the cell.
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
		NPPTableViewCell *cell = (NPPTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
		float oldHeight = cell.cellHeight;
		
		// Performing settings on custom cells.
		NSString *key;
		NSDictionary *properties = [cellCopy objectForKey:kNPPTableProperties];
		properties = (properties != nil) ? properties : [_data objectForKey:kNPPTableCellProperties];
		
		for (key in properties)
		{
			if ([cell respondsToSelector:NSSelectorFromString(key)])
			{
				[cell setValue:[properties objectForKey:key] forKey:key];
			}
		}
		
		// Updates the cell height. When the updateTable is called, it'll use the new height.
		if ((cell.cellHeight != oldHeight))
		{
			[cellCopy setObject:[NSNumber numberWithFloat:cell.cellHeight] forKey:kNPPTableHeight];
		}
		
		// Updates the cell data.
		[cellsData replaceObjectAtIndex:row withObject:cellCopy];
	}
	
	nppRelease(cellCopy);
}

- (void) updateTable
{
	[_tableView beginUpdates];
	[_tableView endUpdates];
}

- (UITableViewCell *) cellSelected
{
	return [self cellForRow:_selectedIndexPath.row inSection:_selectedIndexPath.section];
}

- (UITableViewCell *) cellForRow:(NSInteger)row inSection:(NSInteger)section
{
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
	
	return [_tableView cellForRowAtIndexPath:indexPath];
}

- (NSDictionary *) cellDataForRow:(NSInteger)row inSection:(NSInteger)section
{
	NSMutableDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:section];
	return [[sectionData objectForKey:kNPPTableCells] objectAtIndex:row];
}

- (void) preventCurrentInteraction
{
	_isPreventingInteraction = YES;
}

- (void) markCell:(NSIndexPath *)indexPath
{
	// Marking a cell does not perform any of the NPPTableViewController actions.
	// Just mark a cell as selected.
	UITableViewScrollPosition position = UITableViewScrollPositionTop;
	[_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:position];
}

- (void) selectCell:(NSIndexPath *)indexPath animated:(BOOL)animated
{
	indexPath = [self tableView:_tableView willSelectRowAtIndexPath:indexPath];
	
	// Just performs the selection if the table accept this selection.
	// By default the UIKit doesn't perform this action automatically when selecting directly.
	if (indexPath != nil)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
		{
			UITableViewScrollPosition position = UITableViewScrollPositionTop;
			[_tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:position];
		});
	}
}

- (void) deselectCell:(NSIndexPath *)indexPath animated:(BOOL)animated
{
	indexPath = [self tableView:_tableView willDeselectRowAtIndexPath:indexPath];
	
	// Just performs the deselection if the table accept this selection.
	// By default the UIKit doesn't perform this action automatically when deselecting directly.
	if (indexPath != nil)
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
		{
			[_tableView deselectRowAtIndexPath:indexPath animated:animated];
		});
	}
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
//*************************
//	UIScrollViewDelegate
//*************************

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
	if ([_scrollDelegate respondsToSelector:_cmd])
	{
		[_scrollDelegate scrollViewDidScroll:scrollView];
	}
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if ([_scrollDelegate respondsToSelector:_cmd])
	{
		[_scrollDelegate scrollViewWillBeginDragging:scrollView];
	}
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if ([_scrollDelegate respondsToSelector:_cmd])
	{
		[_scrollDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	}
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if ([_scrollDelegate respondsToSelector:_cmd])
	{
		[_scrollDelegate scrollViewDidEndDecelerating:scrollView];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource
//*************************
//	UITableViewDataSource
//*************************

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return (_isClearing) ? 0 : [[_data objectForKey:kNPPTableSections] count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:section];
	return (_isClearing) ? 0 : [[sectionData objectForKey:kNPPTableCells] count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	NSDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:section];
	NSDictionary *headerData = [sectionData objectForKey:kNPPTableHeader];
	CGFloat height = [[headerData objectForKey:kNPPTableHeight] floatValue];
	
	// Taking the height from Nib file, if the height was not specified in data and the nib exists.
	if (height == 0.0f && headerData != nil)
	{
		height = nppGetTableViewItemHeight(headerData);
	}
	
	return height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	NSDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:section];
	NSDictionary *footerData = [sectionData objectForKey:kNPPTableFooter];
	CGFloat height = [[footerData objectForKey:kNPPTableHeight] floatValue];
	
	// Taking the height from Nib file, if the height was not specified in data and the nib exists.
	if (height == 0.0f && footerData != nil)
	{
		height = nppGetTableViewItemHeight(footerData);
	}
	
	return height;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:section];
	NSDictionary *headerData = [sectionData objectForKey:kNPPTableHeader];
	UIView *view = nppGetTableViewItem(headerData, nil);
	
	// Performing settings on custom cells.
	NSString *key = nil;
	NSDictionary *properties = [headerData objectForKey:kNPPTableProperties];
	
	for (key in properties)
	{
		SEL getter = NSSelectorFromString(key);
		SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@:",[key capitalizedString]]);
		if ([view respondsToSelector:getter] || [view respondsToSelector:setter])
		{
			[view setValue:[properties objectForKey:key] forKey:key];
		}
	}
	
	return view;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	NSDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:section];
	NSDictionary *footerData = [sectionData objectForKey:kNPPTableFooter];
	UIView *view = nppGetTableViewItem(footerData, nil);
	
	// Performing settings on custom cells.
	NSString *key = nil;
	NSDictionary *properties = [footerData objectForKey:kNPPTableProperties];
	
	for (key in properties)
	{
		SEL getter = NSSelectorFromString(key);
		SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@:",[key capitalizedString]]);
		if ([view respondsToSelector:getter] || [view respondsToSelector:setter])
		{
			[view setValue:[properties objectForKey:key] forKey:key];
		}
	}
	
	return view;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:indexPath.section];
	NSDictionary *cellData = [[sectionData objectForKey:kNPPTableCells] objectAtIndex:indexPath.row];
	CGFloat height = [[cellData objectForKey:kNPPTableHeight] floatValue];
	height = (height > 0.0f) ? height : [[_data objectForKey:kNPPTableCellHeight] floatValue];
	
	// Taking the height from Nib file, if the height was not specified in data and the nib exists.
	if (height == 0.0f)
	{
		height = nppGetTableViewItemHeight(cellData);
	}
	
	return (height > 0.0f) ? height : 48.0f;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Local settings override the global ones.
	NSDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:indexPath.section];
	NSDictionary *cellData = [[sectionData objectForKey:kNPPTableCells] objectAtIndex:indexPath.row];
	NSInteger cellsCount = [[sectionData objectForKey:kNPPTableCells] count];
	NSString *className = [cellData objectForKey:kNPPTableClass];
	className = (className != nil) ? className : [_data objectForKey:kNPPTableCellClass];
	
	NPPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:className];
	NSMutableDictionary *cellState = nil;
	
	// Caching cell.
	if (cell == nil)
	{
		// Retrieves the custom class and checks if it's valid.
		className = (className != nil) ? className : _cellClass;
		
		cell = (NPPTableViewCell *)nppGetTableViewItem(cellData, className);
		cell.cellIdentifier = className;
		cell.tableController = self;
	}
	else
	{
		[_dataState setObject:[cell reusableCellState] forKey:cell.indexPath];
		cellState = [_dataState objectForKey:indexPath];
	}
	
	// UITableViewCell customization - indexPath for cell.
	cell.indexPath = indexPath;
	
	// UITableViewCell customization - gestures.
	NPPGesture gestures = _gestures;
	gestures = ([cellData objectForKey:kNPPTableGestureSwipe]) ? gestures | NPPGestureSwipe : gestures;
	gestures = ([cellData objectForKey:kNPPTableGesturePress]) ? gestures | NPPGestureLongPress : gestures;
	cell.enabledGestures = gestures;
	
	// UITableViewCell customization - Defining first and last cells.
	if (cellsCount > 1)
	{
		if (indexPath.row == 0)
		{
			[cell defineFirstCell];
		}
		else if (indexPath.row == cellsCount - 1)
		{
			[cell defineLastCell];
		}
		else
		{
			[cell defineMiddleCell];
		}
	}
	
	// Performing settings on custom cells.
	NSString *key = nil;
	NSDictionary *properties = [cellData objectForKey:kNPPTableProperties];
	properties = (properties != nil) ? properties : [_data objectForKey:kNPPTableCellProperties];
	
	for (key in properties)
	{
		NSString *setKey = [NSString stringWithFormat:@"set%@:", [key stringInverseCamelCase]];
		SEL getter = NSSelectorFromString(key);
		SEL setter = NSSelectorFromString(setKey);
		if ([cell respondsToSelector:getter] || [cell respondsToSelector:setter])
		{
			[cell setValue:[properties objectForKey:key] forKey:key];
		}
	}
	
	// Reusable cell state. There is a big difference between the cell state and cell content.
	// The content is defined by the data, the state is just about the user changes over the original.
	[cell reuseCellWithState:cellState];
	
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate
//*************************
//	UIScrollViewDelegate
//*************************

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)path
{
	if (_lockSelection)
	{
		return nil;
	}
	
	// Preparing the callback method.
	// Local settings override the global ones.
	NSDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:path.section];
	NSDictionary *cellData = [[sectionData objectForKey:kNPPTableCells] objectAtIndex:path.row];
	
	// Action callback.
	NSString *actionName = [cellData objectForKey:kNPPTableAction];
	actionName = (actionName != nil) ? actionName : [_data objectForKey:kNPPTableAction];
	
	// Selection callback.
	NSString *selectionName = [cellData objectForKey:kNPPTableSelection];
	selectionName = (selectionName != nil) ? selectionName : [_data objectForKey:kNPPTableSelection];
	
	// Can select the cell.
	if (actionName != nil || selectionName != nil)
	{
		// Sets the selected cell.
		self.selectedIndexPath = path;
		[_selectedIndexPaths addObjectOnce:path];
		nppPerformAction(_delegate, NSSelectorFromString(actionName));
		nppPerformAction(_delegate, NSSelectorFromString(selectionName));
	}
	// Can't select the cell.
	else
	{
		path = nil;
	}
	
	// Preventing current interaction.
	if (_isPreventingInteraction)
	{
		_isPreventingInteraction = NO;
		[_selectedIndexPaths removeObject:path];
		path = nil;
	}
	
	return path;
}

- (NSIndexPath *) tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)path
{
	[_selectedIndexPaths removeObject:path];
	
	// Preparing the callback method.
	// Local settings override the global ones.
	NSDictionary *sectionData = [[_data objectForKey:kNPPTableSections] objectAtIndex:path.section];
	NSDictionary *cellData = [[sectionData objectForKey:kNPPTableCells] objectAtIndex:path.row];
	
	// Selection callback.
	NSString *selectionName = [cellData objectForKey:kNPPTableSelection];
	selectionName = (selectionName != nil) ? selectionName : [_data objectForKey:kNPPTableSelection];
	
	// Can select the cell.
	if (selectionName != nil)
	{
		// Sets the selected cell.
		nppPerformAction(_delegate, NSSelectorFromString(selectionName));
	}
	
	// Preventing current interaction.
	if (_isPreventingInteraction)
	{
		_isPreventingInteraction = NO;
		[_selectedIndexPaths addObjectOnce:path];
		path = nil;
	}
	
	return path;
}

+ (void) defineCellClassName:(NSString *)cellClassName
{
	nppRelease(_cellClass);
	_cellClass = nppRetain(cellClassName);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) loadView
{
	// Starts the table using the default behavior.
	if (!_customView)
	{
		if (_delegate == nil)
		{
			self.delegate = self;
		}
		
		// Default table size.
		CGRect frame = [[UIScreen mainScreen] applicationFrame];
		frame.origin = CGPointZero;
		
		UIView *aView = [[UIView alloc] initWithFrame:frame];
		self.view = aView;
		nppRelease(aView);
		
		NSString *list = [NSStringFromClass([self class]) stringByAppendingString:@".plist"];
		self.data = [NSDictionary dictionaryWithContentsOfFile:nppMakePath(list)];
	}
}

- (void) dealloc
{
	nppRelease(_tableView);
	nppRelease(_selectedIndexPath);
	nppRelease(_selectedIndexPaths);
	
	nppRelease(_data);
	nppRelease(_dataState);
	
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
#pragma mark Public Categories
#pragma mark -
//**********************************************************************************************************
//
//	Public Categories
//
//**********************************************************************************************************

@implementation NPPDataManager (NPPTableData)

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

+ (NSMutableDictionary *) tableDataWithSections:(NSUInteger)sections rows:(NSUInteger)rows
{
	NSMutableArray *sectionsData = [NSMutableArray array];
	
	NSMutableDictionary *data = nil;
	NSMutableDictionary *section = nil;
	NSMutableArray *cells = nil;
	NSMutableDictionary *cell = nil;
	
	unsigned int i, j;
	for (i = 0; i < sections; ++i)
	{
		cells = [NSMutableArray array];
		section = [NSMutableDictionary dictionaryWithObject:cells forKey:kNPPTableCells];
		[sectionsData addObject:section];
		
		for (j = 0; j < rows; ++j)
		{
			cell = [NSMutableDictionary dictionary];
			[cells addObject:cell];
		}
	}
	
	data = [NSMutableDictionary dictionaryWithObject:sectionsData forKey:kNPPTableSections];
	
	return data;
}

@end
