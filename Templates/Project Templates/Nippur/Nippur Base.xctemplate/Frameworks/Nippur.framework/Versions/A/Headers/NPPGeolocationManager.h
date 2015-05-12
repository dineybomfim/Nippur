/*
 *	NPPGeolocationManager.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 10/1/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"

#import "NPPModelGeolocationVO.h"

#import <CoreLocation/CoreLocation.h>

typedef enum
{
	NPPGeolocationStatusPending,
	NPPGeolocationStatusGranted,
	NPPGeolocationStatusDenied,
} NPPGeolocationStatus;

typedef enum
{
	NPPGeolocationModeGPS,			// + Accurate, + Power consuming
	NPPGeolocationModeCellTower,	// - Accurate, - Power consuming, - Frequent
} NPPGeolocationMode;

// When using the update methods it will return only one item in the "locations" array.
// The continuous indicates if the process should run again.
// The continuous does not work for geolocation routines.
typedef void (^NPPBlockGeolocation)(NPP_ARC_UNSAFE NSArray *items, BOOL *continuous, NSError *error);

@interface NPPGeolocationManager : NSObject

+ (NPPGeolocationStatus) status;

// Get the lastest valid location. Can be outdated.
+ (NPPModelGeolocationVO *) lastGeolocation;

// Current location. Returns NPPModelGeolocationVO as array items.
+ (void) geolocationWithBlock:(NPPBlockGeolocation)block;

// Cancel any scheduled or on going GPS routine.
+ (void) cancelScheduledGeolocations;

// Global definitions.
//TODO Geolocation server.
//+ (void) defineGeolocationServerClass:(Class)aClass index:(unsigned int)index;
+ (void) defineGeolocationRequiredAccuracy:(double)accuracy retries:(int)retries; // Default is 1000 | 0.
+ (void) defineGeolocationMode:(NPPGeolocationMode)mode; // Default NPPGeolocationModeGPS.

@end