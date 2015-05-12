/*
 *	NPPModelAddressVO.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 4/17/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"

#import "NPPModelCountryVO.h"
#import "NPPModelGeolocationVO.h"

NPP_API NSString *const kNPPAddressName;
NPP_API NSString *const kNPPAddressLine1;
NPP_API NSString *const kNPPAddressLine2;
NPP_API NSString *const kNPPAddressNeighborhood;
NPP_API NSString *const kNPPAddressCity;
NPP_API NSString *const kNPPAddressState;
NPP_API NSString *const kNPPAddressCountry;
NPP_API NSString *const kNPPAddressShort;
NPP_API NSString *const kNPPAddressFull;
NPP_API NSString *const kNPPAddressPolitical;

@interface NPPModelAddressVO : NPPModelVO
{
@protected
	int							_tag;
	int							_mode;
	NSString					*_identifier;
	NSString					*_name;
	NSString					*_postalCode;
	NSString					*_line1;
	NSString					*_line2;
	NSString					*_neighborhood;
	NSString					*_city;
	NSString					*_state;
	NPPModelCountryVO			*_country;
	NPPModelGeolocationVO		*_geolocation;
}

@property (nonatomic) int tag;
@property (nonatomic) int mode;
@property (nonatomic, NPP_COPY) NSDate *date;
@property (nonatomic, NPP_COPY) NSString *identifier;
@property (nonatomic, NPP_COPY) NSString *name;
@property (nonatomic, NPP_COPY) NSString *postalCode;
@property (nonatomic, NPP_COPY) NSString *line1;
@property (nonatomic, NPP_COPY) NSString *line2;
@property (nonatomic, NPP_COPY) NSString *neighborhood;
@property (nonatomic, NPP_COPY) NSString *city;
@property (nonatomic, NPP_COPY) NSString *state;
@property (nonatomic, NPP_RETAIN) NPPModelCountryVO *country;
@property (nonatomic, NPP_RETAIN) NPPModelGeolocationVO *geolocation;

/*!
 *					Returns a short representation of the address, for example:
 *					"Av. Paulista, 300"
 *	
 *	@result			An autorelease NSString with the address.
 */
- (NSString *) shortAddress;

/*!
 *					Returns a full representation of the address, for example:
 *					"Av. Paulista, 300 apto. 102 - Bela Vista, São Paulo - SP"
 *	
 *	@result			An autorelease NSString with the address.
 */
- (NSString *) fullAddress;

/*!
 *					Returns a short representation of the political area of the address, for example:
 *					"Bela Vista, São Paulo"
 *					"São Paulo - SP"
 *					"São Paulo"
 *					"SP"
 *
 *					Any of the above combinations can be returned, depending of the current address.
 *					The possible combinations use neighborhood, city and sate fields.
 *
 *	@result			An autorelease NSString with the address.
 */
- (NSString *) politicalAddress;

/*!
 *					Updates the current address with a formated address string.
 *					There are few acceptable fortmats:
 *						- "Av. Paulista (odd), 300-501 apto. 102 - Bela Vista, São Paulo - SP"
 *						- "Av. Paulista (odd) 300-501, Bela Vista, São Paulo, SP, Brazil, 04510-000"
 *						- "300-501 Av. Paulista (odd), Bela Vista, São Paulo, SP - 04510-000, Brazil"
 *
 *	@param			address
 *					A formated address string.
 *
 *	@param			override
 *					Indicates if the existing values will be overrided or not.
 */
- (void) updateWithFormatedAddress:(NSString *)address overriding:(BOOL)override;

/*!
 *					Checks if this address is near to other address. The near algorithm use the "latitude"
 *					and "longitude" properties using a ray in meters.
 *
 *	@param			address
 *					Another NPPModelAddressVO to compare.
 *
 *	@param			meters
 *					The distance in meters to be considered a near address.
 *	
 *	@result			A BOOL indicating if the addresses are near from each other.
 */
- (BOOL) isNearToAddress:(NPPModelAddressVO *)address withRay:(double)meters;

/*!
 *					Checks if this address has geolocation, that is, if the latitude and longitude was set.
 *
 *	@result			A BOOL indicating if there is geolocation information.
 */
- (BOOL) hasGeolocation;

/*!
 *					Calculates the distance from an address to another. Requires geolocation set.
 *
 *	@param			address
 *					The address to calculate the distance from.
 *
 *	@result			A double indicating distance in meters between addresses.
 */
- (double) distanceToAddress:(NPPModelAddressVO *)address;

/*!
 *					Calculates and returns the distance to another address. The distance will be
 *					representent in pretty format, that is, meters or kilometers notation.
 *
 *	@param			address
 *					Another NPPModelAddressVO to compare.
 *
 *	@result			A NSString indicating distance between address.
 */
- (NSString *) distanceStringToAddress:(NPPModelAddressVO *)address;

/*!
 *					Defines the address format to the short address.
 *
 *	@param			format
 *					The should have the property names between signs <>. Ex: <line1> - <line2>
 *
 *	@result			An autorelease NSString with the address.
 */
+ (void) defineShortAddressFormat:(NSString *)format;

/*!
 *					Defines the address format to the short address.
 *
 *	@param			format
 *					The should have the property names between signs <>. Ex: <line1> - <line2>
 *
 *	@result			An autorelease NSString with the address.
 */
+ (void) defineFullAddressFormat:(NSString *)format;

/*!
 *					Defines the address format to the short address.
 *
 *	@param			format
 *					The should have the property names between signs <>. Ex: <line1> - <line2>
 *
 *	@result			An autorelease NSString with the address.
 */
+ (void) definePoliticalAddressFormat:(NSString *)format;

@end