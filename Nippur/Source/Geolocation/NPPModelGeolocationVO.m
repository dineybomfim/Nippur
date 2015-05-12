/*
 *	NPPModelGeolocationVO.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 4/17/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPModelGeolocationVO.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

//#define LENGTH_OF_DEGREE	111100				// meters

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static double nppGeolocationGetDistance(NPPModelGeolocationVO *geoA, NPPModelGeolocationVO *geoB)
{
	double xDistace = fabs(geoA.latitude - geoB.latitude);
	double yDistance = fabs(geoA.longitude - geoB.longitude);
	
	return sqrt(xDistace * xDistace + yDistance * yDistance);
}

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Public Functions
//**************************************************
//	Public Functions
//**************************************************

BOOL nppGeohashesContainsHash(NSArray *geohashes, NSString *hash)
{
	BOOL found = NO;
	NSString *geohash = nil;
	
	// Loop through all geohashes.
	for (geohash in geohashes)
	{
		geohash = [NSString stringWithFormat:@"^%@", geohash];
		
		if (nppRegExMatch(hash, geohash, NPPRegExFlagGDMI))
		{
			found = YES;
			break;
		}
	}
	
	return found;
}

#pragma mark -
#pragma mark Public Class
//**************************************************
//	Public Class
//**************************************************

@implementation NPPModelGeolocationVO

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize latitude = _latitude, longitude = _longitude, haccuracy = _haccuracy,
			altitude = _altitude, vaccuracy = _vaccuracy, speed = _speed, course = _course,
			timestamp = _timestamp;

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) initWithLatitude:(double)latitude longitude:(double)longitude
{
	if ((self = [super init]))
	{
		_latitude = latitude;
		_longitude = longitude;
	}
	
	return self;
}

- (id) initWithGeohash:(NSString *)geohash
{
	if ((self = [super init]))
	{
		[self setGeolocationWithGeohash:geohash];
	}
	
	return self;
}

+ (id) modelWithLatitude:(double)latitude longitude:(double)longitude
{
	NPPModelGeolocationVO *modelVO = [[self alloc] initWithLatitude:latitude longitude:longitude];
	
	return nppAutorelease(modelVO);
}

+ (id) modelWithGeohash:(NSString *)geohash
{
	NPPModelGeolocationVO *modelVO = [[self alloc] initWithGeohash:geohash];
	
	return nppAutorelease(modelVO);
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (BOOL) isValid
{
	BOOL isZero = (_latitude == 0.0 && _longitude == 0.0);
	BOOL isValid = (_latitude <= NPP_GH_MAX_LAT && _latitude >= NPP_GH_MIN_LAT &&
					_longitude <= NPP_GH_MAX_LNG && _longitude >= NPP_GH_MIN_LNG &&
					!isZero);
	
	return isValid;
}

- (BOOL) isNearToGeolocation:(NPPModelGeolocationVO *)geolocation byMeters:(double)meters
{
	double distance = nppGeolocationGetDistance(self, geolocation);
	return (distance <= NPPMetersToGeoDegress(meters));
}

- (BOOL) isFarToGeolocation:(NPPModelGeolocationVO *)geolocation byMeters:(double)meters
{
	double distance = nppGeolocationGetDistance(self, geolocation);
	return (distance >= NPPMetersToGeoDegress(meters));
}

- (double) distanceToGeolocation:(NPPModelGeolocationVO *)geolocation
{
	return NPPGeoDegressToMeters(nppGeolocationGetDistance(self, geolocation));
}

- (NSString *) distanceStringToGeolocation:(NPPModelGeolocationVO *)geolocation
{
	NSString *prettyDistance = nil;
	float distance = NPPGeoDegressToMeters(nppGeolocationGetDistance(self, geolocation));
	
	// Meters
	if (distance < 1000)
	{
		prettyDistance = [NSString stringWithFormat:@"%i m", (int)distance];
	}
	// Kilometers.
	else
	{
		prettyDistance = [NSString stringWithFormat:@"%.2f km", distance * 0.001];
	}
	
	return prettyDistance;
}

- (NSString *) stringValue
{
	return [NSString stringWithFormat:@"%.16g,%.16g", _latitude, _longitude];
}

- (NSString *) geohash
{
	return nppGeohashEncode(_latitude, _longitude, 12);
}

- (NSString *) geohashWithPrecision:(unsigned char)precision
{
	return nppGeohashEncode(_latitude, _longitude, precision);
}

- (void) setGeolocationWithGeohash:(NSString *)geohash
{
	NPPGeocoordinate location = nppGeohashDecode(geohash);
	_latitude = location.latitude;
	_longitude = location.longitude;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) updateWithData:(id)data
{
	// Avoids invalid data formats.
	if (![self checkCompatibility:&data checkClass:[NSDictionary class]])
	{
		return;
	}
	
	// Example:
	// {latitude:1234.1234,longitude:1234.1234,haccuracy:1234.1234,altitude:1234.1234,
	// vaccuracy:1234.1234 speed:1234.1234,course:1234.1234,timestamp:1234.1234}
	
	_latitude = [[data objectForKey:@"lat"] doubleValue];
	_longitude = [[data objectForKey:@"lng"] doubleValue];
	_haccuracy = [[data objectForKey:@"haccuracy"] doubleValue];
	_altitude = [[data objectForKey:@"altitude"] doubleValue];
	_vaccuracy = [[data objectForKey:@"vaccuracy"] doubleValue];
	_speed = [[data objectForKey:@"speed"] doubleValue];
	_course = [[data objectForKey:@"angle"] floatValue];
	_timestamp = [[data objectForKey:@"timestamp"] doubleValue];
}

- (id) dataForJSON
{
	// Better go with string, because it does not loose precision with floating points.
	NSString *latitude = (_latitude != 0.0) ? [NSString stringWithFormat:@"%.16g", _latitude] : nil;
	NSString *longitude = (_longitude != 0.0) ? [NSString stringWithFormat:@"%.16g", _longitude] : nil;
	NSString *haccuracy = (_haccuracy >= 0.0) ? [NSString stringWithFormat:@"%.16g", _haccuracy] : nil;
	NSString *altitude = (_altitude != 0.0) ? [NSString stringWithFormat:@"%.16g", _altitude] : nil;
	NSString *vaccuracy = (_vaccuracy >= 0.0) ? [NSString stringWithFormat:@"%.16g", _vaccuracy] : nil;
	NSString *speed = (_speed >= 0.0) ? [NSString stringWithFormat:@"%.16g", _speed] : nil;
	NSString *course = (_course >= 0.0f) ? [NSString stringWithFormat:@"%f", _course] : nil;
	NSNumber *time = (_timestamp > 0.0) ? [NSNumber numberWithLongLong:_timestamp] : nil;
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	nppDictionaryAdd(latitude, @"lat", dict);
	nppDictionaryAdd(longitude, @"lng", dict);
	nppDictionaryAdd(haccuracy, @"haccuracy", dict);
	nppDictionaryAdd(altitude, @"altitude", dict);
	nppDictionaryAdd(vaccuracy, @"vaccuracy", dict);
	nppDictionaryAdd(speed, @"speed", dict);
	nppDictionaryAdd(course, @"angle", dict);
	nppDictionaryAdd(time, @"timestamp", dict);
	
	return dict;
}

- (BOOL) isEqual:(id)object
{
	BOOL result = NO;
	
	// Use class directly instead of "self", because it compare subclasses as well.
	if ([object isKindOfClass:[NPPModelGeolocationVO class]])
	{
		result = _latitude == [object latitude] && _longitude == [object longitude];
	}
	
	return result;
}

- (void) dealloc
{
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end

#pragma mark -
#pragma mark UIViewController Category
#pragma mark -
//**********************************************************************************************************
//
//	UIViewController Categories
//
//**********************************************************************************************************

@implementation NPPModelGeolocationVO(NPPGeolocation)

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (CLLocation *) CLLocation
{
	NPPModelGeolocationVO *geolocation = self;
	CLLocationCoordinate2D coord = (CLLocationCoordinate2D){ geolocation.latitude, geolocation.longitude };
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:geolocation.timestamp];
	CLLocation *location = [[CLLocation alloc] initWithCoordinate:coord
														 altitude:geolocation.altitude
											   horizontalAccuracy:geolocation.haccuracy
												 verticalAccuracy:geolocation.vaccuracy
														   course:geolocation.course
															speed:geolocation.speed
														timestamp:date];
	
	return nppAutorelease(location);
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end

#pragma mark -
#pragma mark UIViewController Category
#pragma mark -
//**********************************************************************************************************
//
//	UIViewController Categories
//
//**********************************************************************************************************

@implementation CLLocation(NPPGeolocation)

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (NPPModelGeolocationVO *) NPPGeolocation
{
	CLLocation *location = self;
	CLLocationCoordinate2D coordinate = location.coordinate;
	NPPModelGeolocationVO *geolocation = [NPPModelGeolocationVO modelWithLatitude:coordinate.latitude
																		longitude:coordinate.longitude];
	
	geolocation.haccuracy = location.horizontalAccuracy;
	geolocation.altitude = location.altitude;
	geolocation.vaccuracy = location.verticalAccuracy;
	geolocation.speed = location.speed;
	geolocation.course = location.course;
	geolocation.timestamp = [[location timestamp] timeIntervalSince1970];
	
	return geolocation;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end