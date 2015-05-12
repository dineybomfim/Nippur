/*
 *	NPPModelRouteNodeVO.h
 *	Nippur
 *	
 *	Created by Diney Bomfim on 7/13/14.
 *	Copyright 2014 db-in. All rights reserved.
 */

#import "NippurCore.h"

#import "NPPModelGeolocationVO.h"

typedef enum
{
	NPPRouteModeUndefined			= 0,
	NPPRouteModeFoot				= 1,
	NPPRouteModeCar					= 2,
	NPPRouteModeBycicle				= 3,
	NPPRouteModePublicTransport		= 4,
} NPPRouteMode;

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