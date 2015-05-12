/*
 *	NPPModelGeoregionVO.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 5/31/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NippurCore.h"

#import "NPPModelGeolocationVO.h"

@interface NPPModelGeoregionVO : NPPModelVO
{
@private
	NSString					*_name;
	NPPModelGeolocationVO		*_center;
	double						_radius;
}

@property (nonatomic, NPP_COPY) NSString *name;
@property (nonatomic, NPP_RETAIN) NPPModelGeolocationVO *center;
@property (nonatomic) double radius;

+ (id) modelWithName:(NSString *)name center:(NPPModelGeolocationVO *)geolocation radius:(double)radius;

@end