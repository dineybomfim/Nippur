/*
 *	NPPModelRouteNodeVO.h
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

typedef NS_OPTIONS(NSUInteger, NPPRouteMode)
{
	NPPRouteModeUndefined			= 0,
	NPPRouteModeFoot				= 1,
	NPPRouteModeCar					= 2,
	NPPRouteModeBycicle				= 3,
	NPPRouteModePublicTransport		= 4,
};

typedef struct
{
	double latitude;
	double longitude;
} NPPGeoCoordinate;

/*!
 *					A route node can contain many others nodes. Each node specify its own parameters.
 *					However, if there is no internal specification for the node, it will return the sum
 *					of all its nodes, that means, all its sub nodes.
 */
@interface NPPModelRouteNodeVO : NPPModelVO
{
@protected
	NPPRouteMode				_mode;
	unsigned int				_distance;
	unsigned int				_duration;
	NSString					*_encodedPolyline;
	NPPModelGeolocationVO		*_starting;
	NPPModelGeolocationVO		*_ending;
	NSMutableArray				*_nodes;
}

@property (nonatomic) NPPRouteMode mode;
@property (nonatomic) unsigned int distance; // in meters
@property (nonatomic) unsigned int duration; // in seconds
@property (nonatomic, NPP_COPY) NSString *encodedPolyline;
@property (nonatomic, NPP_RETAIN) NPPModelGeolocationVO *starting;
@property (nonatomic, NPP_RETAIN) NPPModelGeolocationVO *ending;
@property (nonatomic, NPP_RETAIN) NSMutableArray *nodes;

- (const NPPGeoCoordinate *) polyline;
- (unsigned int) polylineCount;

@end