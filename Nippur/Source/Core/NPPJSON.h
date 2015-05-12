/*
 *	NPPJSON.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 2/25/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPFunctions.h"
#import "NPPLogger.h"

@protocol NPPJSONSource <NSObject>

@required

/*!
 *					Returns the JSON data for this object. The data must be one of the basic Obj-C objects:
 *					NSString, NSNumber, NSArray or NSDictionary.
 *
 *	@result			One of the Obj-C basic objects representing the data of this model.
 */
- (id) dataForJSON;

@end

@interface NPPJSON : NSObject

// JSON strings.
+ (id) objectWithString:(NSString *)string;
+ (NSString *) stringWithObject:(id)value;

// NSData with UTF-8 encode.
+ (id) objectWithData:(NSData *)data;
+ (NSData *) dataWithObject:(id)value;

/*!
 *					This method defines if the JSON will be generated considering the null values
 *					or not. When defining this method to YES, it means the JSON will completely ignore
 *					keys containing empty, blank and null values.
 *
 *	@param			isSkipping
 *					A BOOL indicating if the next JSONs will skip the empty, blank and null values.
 */
+ (void) defineSkipInvalidParameters:(BOOL)isSkipping;

@end