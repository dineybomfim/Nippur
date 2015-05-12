/*
 *	NPPModelPlaceVO.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 4/25/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"

#import "NPPModelAddressVO.h"

@interface NPPModelPlaceVO : NPPModelVO
{
@protected
	NSString				*_identifier;
	NSString				*_name;
	NPPModelAddressVO		*_address;
	NSString				*_comment;
}

@property (nonatomic, NPP_COPY) NSString *identifier;
@property (nonatomic, NPP_COPY) NSString *name;
@property (nonatomic, NPP_RETAIN) NPPModelAddressVO *address;
@property (nonatomic, NPP_COPY) NSString *comment;

@end