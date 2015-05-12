/*
 *	NPPModelGeolocationVO.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 4/17/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"

#import "NPPGeohash.h"

#import <CoreLocation/CoreLocation.h>

/*!
 *					Checks if a geohash is inside a collection of geohashes. The geohash to be tested,
 *					must have a precision equal or higher than the precisions inside the collection.
 *					For example:
 *						- You can test if ABC9876 is inside ABC9
 *						- You can't test if ABC9 is inside ABC9876, the first one has lower precision.
 *
 *	@result			A BOOL indicating if a geohash is found inside another geohash collection.
 */
NPP_API BOOL nppGeohashesContainsHash(NSArray *geohashes, NSString *hash);

@interface NPPModelGeolocationVO : NPPModelVO
{
@protected
	double						_latitude;
	double						_longitude;
	double						_haccuracy;
	double						_altitude;
	double						_vaccuracy;
	double						_speed;
	float						_course;
	double						_timestamp;
}

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double haccuracy;
@property (nonatomic) double altitude;
@property (nonatomic) double vaccuracy;
@property (nonatomic) double speed;
@property (nonatomic) float course;
@property (nonatomic) double timestamp;

- (id) initWithLatitude:(double)latitude longitude:(double)longitude;
- (id) initWithGeohash:(NSString *)geohash;
+ (id) modelWithLatitude:(double)latitude longitude:(double)longitude;
+ (id) modelWithGeohash:(NSString *)geohash;

/*!
 *					Checks if the geolocation is valid. A geolocation is considered valid when:
 *						- Latitude is in range [-90.0, 90.0].
 *						- Longitude is in range [-180.0, 180.0].
 *						- Latitude and longitude are not both 0.0 at the same time.
 *
 *	@result			A BOOL indicating if the geolocation is valid.
 */
- (BOOL) isValid;

- (BOOL) isNearToGeolocation:(NPPModelGeolocationVO *)geolocation byMeters:(double)meters;
- (BOOL) isFarToGeolocation:(NPPModelGeolocationVO *)geolocation byMeters:(double)meters;

// In meters.
- (double) distanceToGeolocation:(NPPModelGeolocationVO *)geolocation;
- (NSString *) distanceStringToGeolocation:(NPPModelGeolocationVO *)geolocation;

- (NSString *) stringValue;
- (NSString *) geohash;
- (NSString *) geohashWithPrecision:(unsigned char)precision;
- (void) setGeolocationWithGeohash:(NSString *)geohash;

@end

@interface NPPModelGeolocationVO(NPPGeolocation)

- (CLLocation *) CLLocation;

@end

@interface CLLocation(NPPGeolocation)

- (NPPModelGeolocationVO *) NPPGeolocation;

@end