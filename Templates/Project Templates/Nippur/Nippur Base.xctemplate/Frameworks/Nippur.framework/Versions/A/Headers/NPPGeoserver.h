/*
 *	NPPGeoserver.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 5/10/15.
 *	Copyright 2015 db-in. All rights reserved.
 */

#import "NippurCore.h"

#import "NPPModelGeolocationVO.h"
#import "NPPModelGeoregionVO.h"
#import "NPPModelAddressVO.h"

#import <CoreLocation/CoreLocation.h>

typedef void (^NPPBlockGeoserver)(NPP_ARC_UNSAFE NSArray *items, NSError *error);

@protocol NPPGeoserver <NSObject>

@required

// Places routine. Returns NPPModelAddressVO as array items.
+ (void) placeWithRegion:(NPPModelGeoregionVO *)region completion:(NPPBlockGeoserver)block;

// Forward Geocode routine. Returns NPPModelAddressVO as array items.
+ (void) addressWithRegion:(NPPModelGeoregionVO *)region completion:(NPPBlockGeoserver)block;

// Reverse Geocode routine. Returns NPPModelAddressVO as array items.
+ (void) addressWithGeolocation:(NPPModelGeolocationVO *)geolocation completion:(NPPBlockGeoserver)block;

// Routes routine. Returns NPPModelAddressVO as array items.
+ (void) routeFrom:(NPPModelGeolocationVO *)from
				to:(NPPModelGeolocationVO *)to
		completion:(NPPBlockGeoserver)block;

// Cancel all the on going geolocation routines.
+ (void) cancelScheduledAddresses;

@end