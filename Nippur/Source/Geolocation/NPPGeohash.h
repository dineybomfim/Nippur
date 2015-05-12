/*
 *	NPPGeohash.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 2/23/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NippurCore.h"

#define NPP_GH_MIN_LAT			 -90.0
#define NPP_GH_MAX_LAT			 90.0

#define NPP_GH_MIN_LNG			-180.0
#define NPP_GH_MAX_LNG			180.0

typedef struct
{
	double latitude;
	double longitude;
} NPPGeocoordinate;

NPP_API NPPGeocoordinate nppGeohashDecode(NSString *geohash);
NPP_API NSString *nppGeohashEncode(double latitude, double longitude, unsigned char precision);