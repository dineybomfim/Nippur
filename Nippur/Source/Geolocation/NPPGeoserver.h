/*
 *	NPPGeoserver.h
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

#import "NippurCore.h"

#import "NPPModelGeolocationVO.h"
#import "NPPModelGeoregionVO.h"
#import "NPPModelAddressVO.h"

#import <CoreLocation/CoreLocation.h>

typedef void (^nppBlockGeoserver)(NPP_ARC_UNSAFE NSArray *items, NSError *error);

@protocol NPPGeoserver <NSObject>

@required

// Places routine. Returns NPPModelAddressVO as array items.
+ (void) placeWithRegion:(NPPModelGeoregionVO *)region completion:(nppBlockGeoserver)block;

// Forward Geocode routine. Returns NPPModelAddressVO as array items.
+ (void) addressWithRegion:(NPPModelGeoregionVO *)region completion:(nppBlockGeoserver)block;

// Reverse Geocode routine. Returns NPPModelAddressVO as array items.
+ (void) addressWithGeolocation:(NPPModelGeolocationVO *)geolocation completion:(nppBlockGeoserver)block;

// Routes routine. Returns NPPModelAddressVO as array items.
+ (void) routeFrom:(NPPModelGeolocationVO *)from
				to:(NPPModelGeolocationVO *)to
		completion:(nppBlockGeoserver)block;

// Cancel all the on going geolocation routines.
+ (void) cancelScheduledAddresses;

@end