/*
 *	NPPTextFieldManager.h
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

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPInterfaceFunctions.h"

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