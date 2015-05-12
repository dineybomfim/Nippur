/*
 *	NPPTableViewSection.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 10/25/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPTableViewController.h"

@interface NPPTableViewSection : UIView <NPPTableViewItem>
{
@protected
	BOOL								_onTable;
}

// At the initialization time.
- (void) viewDidInit;

// At the first time the section is added to a superview, that means, the layout is completed.
- (void) viewDidLoad;

@end