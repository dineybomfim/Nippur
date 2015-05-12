/*
 *	NPPActionBlock.h
 *	Nippur
 *
 *	The Nippur is a framework for iOS to make daily work easier and more reusable.
 *	This Nippur contains many API and includes many wrappers to other Apple frameworks.
 *
 *	More information at the official web site: http://db-in.com/nippur
 *
 *	Created by Diney Bomfim on 8/12/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NPPAction.h"

/*!
 *					<strong>(Internal only)</strong> Class cluster for #NPPAction#.
 */
@interface NPPActionBlock : NPPAction

- (void) setBlock:(NPPBlockVoid)block;

@end