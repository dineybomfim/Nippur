/*
 *	NPPGeolocationManager.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 10/1/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPGeolocationManager.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define NPP_GEO_FILE				@"NPPGeolocation"
#define NPP_GEO_ERROR_INVALID		@"NPPGeolocationManager Invalid Operation"
#define NPP_GEO_ERROR_BACKGROUND	@"NPPGeolocationManager can't run in background mode for this app"
#define NPP_GEO_ERROR_PROTOCOL		@"The %@ does not implements the protocol NPPGeoserver."

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

static NPPGeolocationManager *_defaultLocationManager = nil;
static double _defaultAccuracy = 1000.0;
static int _defaultRetries = 0;
static int _defaultMode = NPPGeolocationModeGPS;

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

@interface NPPGeolocationManager() <CLLocationManagerDelegate>
{
	NSMutableArray					*_callbacks;
	CLLocationManager				*_locationManager;
	unsigned int					_currentRetry;
}

@property (nonatomic, NPP_RETAIN) CLLocation *bestLocation;
@property (nonatomic, NPP_RETAIN) NPPModelGeolocationVO *lastGeolocation;

// Initializes a new instance.
- (void) initializing;

- (void) addListenerWithBlock:(NPPBlockGeolocation)block;

- (void) startMonitoring;
- (void) stopMonitoring;

@end

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPGeolocationManager

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

@synthesize bestLocation = _bestLocation, lastGeolocation = _lastGeolocation;

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

#pragma mark -
#pragma mark Private Methods
//**************************************************
//	Private Methods
//**************************************************

- (void) initializing
{
	_callbacks = [[NSMutableArray alloc] init];
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	_currentRetry = 0;
}

- (void) addListenerWithBlock:(NPPBlockGeolocation)block
{
	// Avoids invalid blocks.
	if (block == nil)
	{
		return;
	}
	
	// Blocks can't be directly retained, by its nature, they must be copied.
	id copyblock = [block copy];
	[_callbacks addObject:copyblock];
	nppRelease(copyblock);
	
	// Basic setup.
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	nppPerformAction(_locationManager, @selector(requestAlwaysAuthorization));
	
	[self startMonitoring];
}

- (void) startMonitoring
{
	switch (_defaultMode)
	{
		case NPPGeolocationModeCellTower:
			[_locationManager startMonitoringSignificantLocationChanges];
			break;
		case NPPGeolocationModeGPS:
		default:
			[_locationManager startUpdatingLocation];
			break;
	}
}

- (void) stopMonitoring
{
	[_locationManager stopMonitoringSignificantLocationChanges];
	[_locationManager stopUpdatingLocation];
	[_callbacks removeAllObjects];
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

#pragma mark -
#pragma mark CLLocationManager Delegate
//*************************
//	CLLocationManager Delegate
//*************************

- (void) locationManager:(CLLocationManager *)manager
	 didUpdateToLocation:(CLLocation *)newLocation
			fromLocation:(CLLocation *)oldLocation
{
	[self locationManager:manager
	   didUpdateLocations:[NSArray arrayWithObjects:oldLocation, newLocation, nil]];
}

- (void) locationManager:(CLLocationManager *)manager
	  didUpdateLocations:(NSArray *)locations
{
	BOOL continuous = NO;
	NPPBlockGeolocation callback = nil;
	NSArray *blocks = nil;
	NSArray *array = nil;
	CLLocation *lastLocation = [locations lastObject];
	
	// Choosing between the best accuracies.
	if (_bestLocation == nil || lastLocation.horizontalAccuracy < _bestLocation.horizontalAccuracy)
	{
		self.bestLocation = lastLocation;
		self.lastGeolocation = lastLocation.NPPGeolocation;
		[_lastGeolocation saveToFile:NPP_GEO_FILE folder:NPPDataFolderNippur];
	}
	
	// If the required accuracy was not reached yet, give it another try.
	if (_bestLocation.horizontalAccuracy > _defaultAccuracy && _currentRetry < _defaultRetries)
	{
		++_currentRetry;
		return;
	}
	
	// Getting the callbacks to start executing them.
	blocks = [NSArray arrayWithArray:_callbacks];
	array = [NSArray arrayWithObject:_lastGeolocation];
	
	for (callback in blocks)
	{
		continuous = NO;
		nppBlock(callback, array, &continuous, nil);
		
		// Removes only non continuous callbacks.
		if (!continuous)
		{
			[_callbacks removeObjectIdenticalTo:callback];
		}
	}
	
	// Just stop the location update when there are no more listeners.
	if ([_callbacks count] == 0)
	{
		[self stopMonitoring];
	}
	
	// Cleaning up the retires and required accuracy routine.
	self.bestLocation = nil;
	_currentRetry = 0;
}

- (void) locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	switch (status)
	{
		// When authorized, forces the start to make sure the last location will be the most recent.
		case kCLAuthorizationStatusAuthorizedAlways:
			[self startMonitoring];
			break;
		// When denied or blocked, stop updating the location. The OS does it automatically when
		// user denied explicity, but it does not when the block comes from outside.
		default:
			[self stopMonitoring];
			break;
	}
}

#pragma mark -
#pragma mark Self Methods
//*************************
//	Self Methods
//*************************

+ (NPPGeolocationStatus) status
{
	CLAuthorizationStatus clStatus = [CLLocationManager authorizationStatus];
	NPPGeolocationStatus status = NPPGeolocationStatusDenied;
	
	switch (clStatus)
	{
		case kCLAuthorizationStatusNotDetermined:
			status = NPPGeolocationStatusPending;
			break;
		case kCLAuthorizationStatusDenied:
			status = NPPGeolocationStatusDenied;
			break;
		default:
			status = NPPGeolocationStatusGranted;
			break;
	}
	
	return status;
}

+ (NPPModelGeolocationVO *) lastGeolocation
{
	return _defaultLocationManager.lastGeolocation;
}

+ (void) geolocationWithBlock:(NPPBlockGeolocation)block
{
	[_defaultLocationManager addListenerWithBlock:block];
}

+ (void) cancelScheduledGeolocations
{
	[_defaultLocationManager stopMonitoring];
}

+ (void) defineGeolocationRequiredAccuracy:(double)accuracy retries:(int)retries
{
	_defaultAccuracy = MAX(accuracy, 7.0f);
	_defaultRetries = MAX(retries, 0);
}

+ (void) defineGeolocationMode:(NPPGeolocationMode)mode
{
	_defaultMode = mode;
	[_defaultLocationManager stopMonitoring];
	[_defaultLocationManager startMonitoring];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
	nppRelease(_callbacks);
	nppRelease(_locationManager);
	nppRelease(_bestLocation);
	nppRelease(_lastGeolocation);
	
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

+ (void) initialize
{
	if (self == [NPPGeolocationManager class])
	{
		_defaultLocationManager = [[NPPGeolocationManager alloc] init];
		_defaultLocationManager.lastGeolocation = [NPPDataManager loadLocal:NPP_GEO_FILE
																	   type:NPPDataTypeArchive
																	 folder:NPPDataFolderNippur];
	}
}

@end