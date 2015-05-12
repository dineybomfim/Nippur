/*
 *	NPPTextFieldManager.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 4/9/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

// Predefined formats:
//	# = Number
//	@ = Upper Case Letter
//	* = Insensitive Case Letter

#define kDB_FORMAT_CEP			@"#####-###"
#define kDB_FORMAT_STATE		@"@@"
#define kDB_FORMAT_CPF			@"###.###.###-##"
#define kDB_FORMAT_CAR_PLATE	@"@@@ ####"
#define kDB_FORMAT_PHONE		@"####-####"
#define kDB_FORMAT_PHONE_DDD	@"##"
#define kDB_FORMAT_DATE			@"##/##/####"
#define kDB_FORMAT_HOUR			@"##:##"

@interface NPPTextFieldManager : NSObject

// The formater should use # for numbers and @ for characters. All other signs will be used as literal.
+ (void) setTextField:(UITextField *)textField format:(NSString *)format;

// Removes the text field. Must be called to release the text field instance.
+ (void) removeTextField:(UITextField *)textField;

// Removes all the text fields.
+ (void) removeAll;

@end