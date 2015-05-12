/*
 *	NPPGeolocationManager.h
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