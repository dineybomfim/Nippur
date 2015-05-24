/*
 *	NPPModelRouteNodeVO.m
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

#import "NPPModelRouteNodeVO.h"

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

typedef struct
{
	NPPGeoCoordinate *points;
	unsigned int count;
} NPPRoutePolyline;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************
/*
static NSString *nppRouteEncodePolyline(NPPRoutePolyline *polyline)
{
	NSMutableString *encodedString = [NSMutableString string];
	NPPGeoCoordinate prevCoordinate = { 0.0, 0.0 };
	int val = 0;
	int value = 0;
	unsigned int i = 0;
	unsigned int length = (*polyline).count;
	NPPGeoCoordinate *coords = (*polyline).points;
	
	for (i = 0; i < length; ++i)
	{
		NPPGeoCoordinate coordinate = *coords++;
		
		// Encoding latitude.
		val = round((coordinate.latitude - prevCoordinate.latitude) * 1e5);
		val = (val < 0) ? ~(val << 1) : (val << 1);
		
		while (val >= 0x20)
		{
			int value = (0x20|(val & 31)) + 63;
			[encodedString appendFormat:@"%c", value];
			val >>= 5;
		}
		
		[encodedString appendFormat:@"%c", val + 63];
		
		// Encoding longitude.
		val = round((coordinate.longitude - prevCoordinate.longitude) * 1e5);
		val = (val < 0) ? ~(val << 1) : (val << 1);
		
		while (val >= 0x20)
		{
			value = (0x20 | (val & 31)) + 63;
			[encodedString appendFormat:@"%c", value];
			val >>= 5;
		}
		
		[encodedString appendFormat:@"%c", val + 63];
		
		prevCoordinate = coordinate;
	}
	
	return encodedString;
}
//*/
static void nppRouteDecodePolyline(NSString *encodedString, NPPRoutePolyline *polyline)
{
	const char *bytes = [encodedString UTF8String];
	NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSUInteger idx = 0;
	NSUInteger count = length / 4;
	
	char byte = 0;
	int res = 0;
	char shift = 0;
	double latitude = 0;
	double longitude = 0;
	double deltaLat = 0.0f;
	double deltaLng = 0.0f;
	double finalLat = 0.0f;
	double finalLon = 0.0f;
	int size = sizeof(NPPGeoCoordinate);
	
	(*polyline).points = realloc((*polyline).points, size * count);
	memset((*polyline).points, 0, size * count);
	(*polyline).count = 0;
	NPPGeoCoordinate *coords = (*polyline).points;
	
	while (idx < length)
	{
		res = 0;
		shift = 0;
		
		do
		{
			byte = bytes[idx++] - 63;
			res |= (byte & 0x1F) << shift;
			shift += 5;
		} while (byte >= 0x20);
		
		deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
		latitude += deltaLat;
		
		shift = 0;
		res = 0;
		
		do
		{
			byte = bytes[idx++] - 0x3F;
			res |= (byte & 0x1F) << shift;
			shift += 5;
		} while (byte >= 0x20);
		
		deltaLng = ((res & 1) ? ~(res >> 1) : (res >> 1));
		longitude += deltaLng;
		
		finalLat = latitude * 1E-5;
		finalLon = longitude * 1E-5;
		
		*coords++ = (NPPGeoCoordinate){ finalLat, finalLon };
		(*polyline).count += 1;
		
		if ((*polyline).count == count)
		{
			NSUInteger newCount = count + 10;
			(*polyline).points = realloc((*polyline).points, newCount * size);
			count = newCount;
		}
	}
}

#pragma mark -
#pragma mark Private Category
//**************************************************
//	Private Category
//**************************************************

@interface NPPModelRouteNodeVO()
{
@private
	NPPRoutePolyline			_polyline;
}

- (void) initializing;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPModelRouteNodeVO

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize mode = _mode, nodes = _nodes;

@dynamic distance, duration, encodedPolyline, starting, ending;

- (unsigned int) distance
{
	unsigned int distance = _distance;
	
	if (distance == 0)
	{
		NPPModelRouteNodeVO *routeVO = nil;
		
		for (routeVO in _nodes)
		{
			distance += routeVO.distance;
		}
	}
	
	return distance;
}

- (void) setDistance:(unsigned int)value
{
	_distance = value;
}

- (unsigned int) duration
{
	unsigned int duration = _duration;
	
	if (duration == 0)
	{
		NPPModelRouteNodeVO *routeVO = nil;
		
		for (routeVO in _nodes)
		{
			duration += routeVO.duration;
		}
	}
	
	return duration;
}

- (void) setDuration:(unsigned int)value
{
	_duration = value;
}

- (NSString *) encodedPolyline { return _encodedPolyline; }
- (void) setEncodedPolyline:(NSString *)value
{
	if (![_encodedPolyline isEqualToString:value])
	{
		nppRelease(_encodedPolyline);
		_encodedPolyline = [value copy];
	}
}

- (NPPModelGeolocationVO *) starting
{
	NPPModelGeolocationVO *starting = _starting;
	
	if (starting == nil)
	{
		starting = [[_nodes firstObject] starting];
	}
	
	return starting;
}

- (void) setStarting:(NPPModelGeolocationVO *)value
{
	nppRelease(_starting);
	_starting = nppRetain(value);
}

- (NPPModelGeolocationVO *) ending
{
	NPPModelGeolocationVO *ending = _ending;
	
	if (ending == nil)
	{
		ending = [[_nodes lastObject] ending];
	}
	
	return ending;
}

- (void) setEnding:(NPPModelGeolocationVO *)value
{
	nppRelease(_ending);
	_ending = nppRetain(value);
}

#pragma mark -
#pragma mark Constructors
//**************************************************
//	Constructors
//**************************************************

- (id) init
{
	if ((self = [super init]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithData:(id)data
{
	if ((self = [super initWithData:data]))
	{
		[self initializing];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self initializing];
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	_polyline.points = malloc(sizeof(NPPGeoCoordinate));
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

- (const NPPGeoCoordinate *) polyline
{
	if (_polyline.points == NULL && [_encodedPolyline length] > 0)
	{
		nppRouteDecodePolyline(_encodedPolyline, &_polyline);
	}
	
	return _polyline.points;
}

- (unsigned int) polylineCount
{
	return _polyline.count;
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
	// {mode:1,distance:124,duration:123,starting:{...},ending:{...},polyline:Aed325g
	// nodes:{...}}
	
	self.mode = [[data objectForKey:@"mode"] intValue];
	self.distance = [[data objectForKey:@"distance"] intValue];
	self.duration = [[data objectForKey:@"duration"] intValue];
	self.encodedPolyline = [data objectForKey:@"polyline"];
	self.starting = [NPPModelGeolocationVO modelWithData:[data objectForKey:@"starting"]];
	self.ending = [NPPModelGeolocationVO modelWithData:[data objectForKey:@"ending"]];
	
	//*************************
	//	Sub-nodes
	//*************************
	
	NSMutableArray *nodes = [[NSMutableArray alloc] init];
	NSArray *nodesData = [data objectForKey:@"nodes"];
	NSDictionary *routeData = nil;
	
	for (routeData in nodesData)
	{
		[nodes addObject:[NPPModelRouteNodeVO modelWithData:routeData]];
	}
	
	self.nodes = nodes;
	nppRelease(nodes);
}

- (id) dataForJSON
{
	NPPModelGeolocationVO *starting = self.starting;
	NPPModelGeolocationVO *ending = self.ending;
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObjectSafely:[NSNumber numberWithInt:_mode] forKey:@"mode"];
	[dict setObjectSafely:[NSNumber numberWithInt:self.distance] forKey:@"distance"];
	[dict setObjectSafely:[NSNumber numberWithInt:self.duration] forKey:@"duration"];
	[dict setObjectSafely:_encodedPolyline forKey:@"polyline"];
	[dict setObjectSafely:starting forKey:@"starting"];
	[dict setObjectSafely:ending forKey:@"ending"];
	[dict setObjectSafely:_nodes forKey:@"nodes"];
	
	return dict;
}

- (void) dealloc
{
	nppFree(_polyline.points);
	
	nppRelease(_encodedPolyline);
	nppRelease(_starting);
	nppRelease(_ending);
	nppRelease(_nodes);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

@end
