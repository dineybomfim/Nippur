/*
 *	NPPGeohash.m
 *	Nippur
 *	
 *	Created by Diney Bomfim on 2/23/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NPPGeohash.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

static const char _nppGeohashTable[32] = "0123456789bcdefghjkmnpqrstuvwxyz";

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

#pragma mark -
#pragma mark Public Functions
//**************************************************
//	Public Functions
//**************************************************

NSString *nppGeohashEncode(double latitude, double longitude, unsigned char precision)
{
	NSString *geohash = nil;
	char *hash = NULL;
	BOOL isEven = YES;
	unsigned char hashChar = 0;
	unsigned char bit = 0;
	unsigned char i = 0;
	double latInterval[2] = { NPP_GH_MIN_LAT, NPP_GH_MAX_LAT };
	double lngInterval[2] = { NPP_GH_MIN_LNG, NPP_GH_MAX_LNG };
	double mid = 0.0;
	
	precision = MAX(precision, 12);
	
	// Just run for valid coordinates, that means inside the range [-90, 90] and [-180, 180].
	if (latitude <= NPP_GH_MAX_LAT && latitude >= NPP_GH_MIN_LAT &&
		longitude <= NPP_GH_MAX_LNG && longitude >= NPP_GH_MIN_LNG)
	{
		// Allocating the hash memory.
		hash = malloc((precision + 1) * NPP_SIZE_CHAR);
		hash[precision] = '\0';
		
		while (i < precision)
		{
			// Moving the current hash char one bit left,
			// because during the mid comparison, it'll suffer OR bitwise operation with 1.
			hashChar = hashChar << 1;
			
			// By geohash algorithm, even bits means longitude.
			if (isEven)
			{
				mid = (lngInterval[0] + lngInterval[1]) * 0.5;
				if (longitude > mid)
				{
					hashChar |= 0x01;
					lngInterval[0] = mid;
				}
				else
				{
					lngInterval[1] = mid;
				}
			}
			// By geohash algorithm, odd bits means latitude.
			else
			{
				mid = (latInterval[0] + latInterval[1]) * 0.5;
				if (latitude > mid)
				{
					hashChar |= 0x01;
					latInterval[0] = mid;
				}
				else
				{
					latInterval[1] = mid;
				}
			}
			
			// Changes the even/odd for the next loop.
			isEven = !isEven;
			
			// Keep running until full fill a half byte (4 bits).
			if (bit < 4)
			{
				++bit;
			}
			// When the half byte (4 bits) is full filled, add it to the final geohash.
			else
			{
				hash[i++] = _nppGeohashTable[hashChar];
				hashChar = 0;
				bit = 0;
			}
		}
		
		geohash = [NSString stringWithUTF8String:hash];
		nppFree(hash);
	}
	
	return geohash;
}

NPPGeocoordinate nppGeohashDecode(NSString *geohash)
{
	NPPGeocoordinate location = (NPPGeocoordinate){ 0.0, 0.0 };
	BOOL isEven = YES;
	double delta = 0.0;
	double latInterval[2] = { NPP_GH_MIN_LAT, NPP_GH_MAX_LAT };
	double lngInterval[2] = { NPP_GH_MIN_LNG, NPP_GH_MAX_LNG };
	const char *hash = [geohash UTF8String];
	char *charFind = NULL;
	unsigned int charIndex = 0;
	unsigned int length = 0;
	unsigned char bit = 0;
	unsigned char i = 0;
	
	if (geohash != nil)
	{
		length = (unsigned int)strlen(hash);
		/*
		for (i  = 0; i < length; ++i)
		{
			charFind = strchr(_nppGeohashTable, hash[i]);
			charIndex = charFind - _nppGeohashTable;
			
			for (bit = 0; bit < 5; ++bit)
			{
				// By geohash algorithm, even bits means longitude.
				if (isEven)
				{
					delta = (lngInterval[1] - lngInterval[0]) * 0.5;
					if ((charIndex << bit) & 0x10)
					{
						lngInterval[0] += delta;
					}
					else
					{
						lngInterval[1] -= delta;
					}
					
				}
				// By geohash algorithm, odd bits means latitude.
				else
				{
					delta = (latInterval[1] - latInterval[0]) * 0.5;
					if ((charIndex << bit) & 0x10)
					{
						latInterval[0] += delta;
					}
					else
					{
						latInterval[1] -= delta;
					}
				}
				
				// Changes the even/odd for the next loop.
				isEven = !isEven;
			}
		}
		
		location.latitude = latInterval[1] - ((latInterval[1] - latInterval[0]) * 0.5);
		location.longitude = lngInterval[1] - ((lngInterval[1] - lngInterval[0]) * 0.5);
		/*/
		for (i  = 0; i < length; ++i)
		{
			charFind = strchr(_nppGeohashTable, hash[i]);
			charIndex = (unsigned int)(charFind - _nppGeohashTable);
			
			for (bit = 0; bit < 5; ++bit)
			{
				// By geohash algorithm, even bits means longitude.
				if (isEven)
				{
					delta = (lngInterval[0] + lngInterval[1]) * 0.5;
					if (charIndex & (0x10 >> bit))
					{
						lngInterval[0] = delta;
					}
					else
					{
						lngInterval[1] = delta;
					}
				}
				// By geohash algorithm, odd bits means latitude.
				else
				{
					delta = (latInterval[0] + latInterval[1]) * 0.5;
					if (charIndex & (0x10 >> bit))
					{
						latInterval[0] = delta;
					}
					else
					{
						latInterval[1] = delta;
					}
				}
				
				// Changes the even/odd for the next loop.
				isEven = !isEven;
			}
		}
		
		location.latitude = (latInterval[0] + latInterval[1]) * 0.5;
		location.longitude = (lngInterval[0] + lngInterval[1]) * 0.5;
		//*/
	}
	
	return location;
}

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
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

/*
#define NORTH			   0
#define EAST				1
#define SOUTH			   2
#define WEST				3

static char *even_neighbors[] = {
	"p0r21436x8zb9dcf5h7kjnmqesgutwvy",
	"bc01fg45238967deuvhjyznpkmstqrwx",
	"14365h7k9dcfesgujnmqp0r2twvyx8zb",
	"238967debc01fg45kmstqrwxuvhjyznp"
};

static char *odd_neighbors[] = {
	"bc01fg45238967deuvhjyznpkmstqrwx",
	"p0r21436x8zb9dcf5h7kjnmqesgutwvy",
	"238967debc01fg45kmstqrwxuvhjyznp",
	"14365h7k9dcfesgujnmqp0r2twvyx8zb"
};

static char *even_borders[] = {"prxz", "bcfguvyz", "028b", "0145hjnp"};
static char *odd_borders[] = {"bcfguvyz", "prxz", "0145hjnp", "028b"};

char* get_neighbor(char *hash, int direction) {
	
	int hash_length = strlen(hash);
	
	char last_char = hash[hash_length - 1];
	
	int is_odd = hash_length % 2;
	char **border = is_odd ? odd_borders : even_borders;
	char **neighbor = is_odd ? odd_neighbors : even_neighbors;
	
	char *base = malloc(sizeof(char) * 1);
	base[0] = '\0';
	strncat(base, hash, hash_length - 1);
	
	if(index_for_char(last_char, border[direction]) != -1)
		base = get_neighbor(base, direction);
	
	int neighbor_index = index_for_char(last_char, neighbor[direction]);
	last_char = _nppGeohashTable[neighbor_index];
	
	char *last_hash = malloc(sizeof(char) * 2);
	last_hash[0] = last_char;
	last_hash[1] = '\0';
	strcat(base, last_hash);
	free(last_hash);
	
	return base;
}

char** geohash_neighbors(char *hash) {
	
	char** neighbors = NULL;
	
	if(hash) {
		
		// N, NE, E, SE, S, SW, W, NW
		neighbors = (char**)malloc(sizeof(char*) * 8);
		
		neighbors[0] = get_neighbor(hash, NORTH);
		neighbors[1] = get_neighbor(neighbors[0], EAST);
		neighbors[2] = get_neighbor(hash, EAST);
		neighbors[3] = get_neighbor(neighbors[2], SOUTH);
		neighbors[4] = get_neighbor(hash, SOUTH);
		neighbors[5] = get_neighbor(neighbors[4], WEST);
		neighbors[6] = get_neighbor(hash, WEST);
		neighbors[7] = get_neighbor(neighbors[6], NORTH);
		
	}
	
	return neighbors;
}

GeoBoxDimension geohash_dimensions_for_precision(int precision) {
	
	GeoBoxDimension dimensions = {0.0, 0.0};
	
	if(precision > 0) {
		
		int lat_times_to_cut = precision * 5 / 2;
		int lng_times_to_cut = precision * 5 / 2 + (precision % 2 ? 1 : 0);
		
		double width = 360.0;
		double height = 180.0;
		
		int i;
		for(i = 0; i < lat_times_to_cut; i++)
			height /= 2.0;
		
		for(i = 0; i < lng_times_to_cut; i++)
			width /= 2.0;
		
		dimensions.width = width;
		dimensions.height = height;
		
	}
	
	return dimensions;
}
//*/