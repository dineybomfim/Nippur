/*
 *	NPPGeoserverApple.m
 *	Nippur
 *	
 *	Created by Diney Bomfim on 3/30/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPGeoserverApple.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

NPP_STATIC_READONLY(nppGetCLGeocoder, CLGeocoder);

static NPPModelAddressVO *nppAddressFromPlacemark(CLPlacemark *placemark)
{
	if (placemark == nil)
	{
		return nil;
	}
	
	NPPModelAddressVO *addressVO = [[NPPModelAddressVO alloc] init];
	NPPModelCountryVO *country = [[NPPModelCountryVO alloc] init];
	NSDictionary *address = [placemark addressDictionary];
	NSString *name = placemark.name;
	NSString *line1 = placemark.thoroughfare;
	NSString *line2 =  placemark.subThoroughfare;
	NSString *postalCode = [placemark postalCode];
	NSString *postalCodeExtension = [address objectForKey:@"PostCodeExtension"];
	
	if (postalCodeExtension != nil)
	{
		postalCode = [postalCode stringByAppendingFormat:@"-%@", postalCodeExtension];
	}
	
	// Excluding names that is redundant, containing other parts of the address.
	name = (nppRegExMatch(name, postalCode, NPPRegExFlagGDMI)) ? nil : name;
	name = (nppRegExMatch(name, line1, NPPRegExFlagGDMI)) ? nil : name;
	
	// Country.
	country.isoCode = placemark.ISOcountryCode;
	country.name = placemark.country;
	[country makeBasedOnISOCode];
	
	// Address.
	addressVO.tag = 1; // Tag = 1 identifies Apple search.
	addressVO.name = name;
	addressVO.postalCode = postalCode;
	addressVO.line1 = line1;
	addressVO.line2 = line2;
	addressVO.neighborhood = placemark.subLocality;
	addressVO.city = placemark.locality;
	addressVO.state = placemark.administrativeArea;
	addressVO.country = country;
	addressVO.geolocation = placemark.location.NPPGeolocation;
	
	// Just a final check pass, to make sure any region, with a valid address format, will be count.
	//formatted = [[address objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
	//[addressVO updateWithFormatedAddress:formatted overriding:NO];
	
	nppRelease(country);
	
	return nppAutorelease(addressVO);
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPGeoserverApple

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

#pragma mark -
#pragma mark NPPGeolocation
//*************************
// NPPGeolocation
//*************************

+ (void) placeWithRegion:(NPPModelGeoregionVO *)region completion:(NPPBlockGeoserver)block
{
	//TODO
}

+ (void) addressWithRegion:(NPPModelGeoregionVO *)region completion:(NPPBlockGeoserver)block
{
	id clRegion = nil;
	NSString *address = region.name;
	CLLocation *location = [[region center] CLLocation];
	double radius = region.radius;
	
	if (location != nil)
	{
		Class regionClass = NSClassFromString(@"CLCircularRegion");
		
		if (regionClass != Nil)
		{
			clRegion = [[regionClass alloc] initWithCenter:location.coordinate
													radius:radius
												identifier:nil];
		}
		else
		{
			regionClass = NSClassFromString(@"CLRegion");
			clRegion = [[regionClass alloc] initCircularRegionWithCenter:location.coordinate
																  radius:radius
															  identifier:nil];
		}
	}
	
	CLGeocoder *geocoder = nppGetCLGeocoder();
	[geocoder geocodeAddressString:address
						  inRegion:clRegion
				 completionHandler:^(NSArray *placemarks, NSError *error)
	 {
		 CLPlacemark *placemark = nil;
		 NSMutableArray *array = [NSMutableArray array];
		 
		 for (placemark in placemarks)
		 {
			 [array addObject:nppAddressFromPlacemark(placemark)];
		 }
		 
		 nppBlock(block, array, error);
	 }];
	
	nppRelease(clRegion);
}

+ (void) addressWithGeolocation:(NPPModelGeolocationVO *)geolocation completion:(NPPBlockGeoserver)block
{
	CLGeocoder *geocoder = nppGetCLGeocoder();
	[geocoder reverseGeocodeLocation:geolocation.CLLocation
				   completionHandler:^(NSArray *placemarks, NSError *error)
	{
		CLPlacemark *placemark = nil;
		NSMutableArray *array = [NSMutableArray array];
		
		for (placemark in placemarks)
		{
			[array addObject:nppAddressFromPlacemark(placemark)];
		}
		
		nppBlock(block, array, error);
	}];
}

+ (void) routeFrom:(NPPModelGeolocationVO *)from
				to:(NPPModelGeolocationVO *)to
		completion:(NPPBlockGeoserver)block
{
	//TODO
	
	/*
	 MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
	 request.naturalLanguageQuery = @"restaurant";
	 
	 MKCoordinateSpan span = MKCoordinateSpanMake(.0001, .0001);
	 request.region = MKCoordinateRegionMake(geolocation.CLLocation.coordinate, span);
	 
	 MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
	 [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
	 {
	 // Handle results
	 }];
	 //*/
}

+ (void) cancelScheduledAddresses
{
	CLGeocoder *geocoder = nppGetCLGeocoder();
	[geocoder cancelGeocode];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

@end