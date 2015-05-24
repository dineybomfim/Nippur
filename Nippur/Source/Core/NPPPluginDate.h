/*
 *	NPPPluginDate.h
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

#import "NPPRuntime.h"

/*!
 *					This category is a wrapper to the date object. It brings easy methods to deal with
 *					epoch timestamps, date manipulations and date formats.
 */
@interface NSDate(NPPDate)

/*!
 *					The full year of this date with all digits.
 */
@property (nonatomic, readonly) NSUInteger year;

/*!
 *					The month of this date with 2 digits.
 */
@property (nonatomic, readonly) NSUInteger month;

/*!
 *					The month of this date with 2 digits.
 */
@property (nonatomic, readonly) NSUInteger day;

/*!
 *					The month of this date with 1 digits, where 1 = Sunday and 7 = Saturday.
 */
@property (nonatomic, readonly) NSUInteger weekDay;

/*!
 *					The hour of this date with 2 digits.
 */
@property (nonatomic, readonly) NSUInteger hour;

/*!
 *					The minutes of this date with 2 digits.
 */
@property (nonatomic, readonly) NSUInteger minute;

/*!
 *					The seconds of this date with 2 digits.
 */
@property (nonatomic, readonly) NSUInteger second;

/*!
 *					Returns a new date with 1 minute from this date.
 *
 *	@result			A new autoreleased date.
 */
- (NSDate *) nextMinute;

/*!
 *					Returns a new date with 1 hour from this date.
 *
 *	@result			A new autoreleased date.
 */
- (NSDate *) nextHour;

/*!
 *					Returns a new date with 1 day from this date.
 *
 *	@result			A new autoreleased date.
 */
- (NSDate *) nextDay;

/*!
 *					Returns a new date with 1 month from this date.
 *
 *	@result			A new autoreleased date.
 */
- (NSDate *) nextMonth;

/*!
 *					Returns a new date with 1 year from this date.
 *
 *	@result			A new autoreleased date.
 */
- (NSDate *) nextYear;

/*!
 *					Returns a new date with variable minutes, hours, days, months and years from this date.
 *
 *	@param			minutes
 *					The minutes from this date.
 *
 *	@param			hours
 *					The hours from this date.
 *
 *	@param			days
 *					The days from this date.
 *
 *	@param			months
 *					The months from this date.
 *
 *	@param			years
 *					The years from this date.
 *
 *	@result			A new autoreleased date.
 */
- (NSDate *) dateByAddingMinutes:(int)minutes
						   hours:(int)hours
							days:(int)days
						  months:(int)months
						   years:(int)years;

/*!
 *					Generates a string from this date with a specific format.
 *
 *	@param			format
 *					The format you want, following the format patterns Unicode Technical Standard #35:
 *					http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 *
 *	@result			A new autoreleased string.
 */
- (NSString *) stringWithFormat:(NSString *)format;

/*!
 *					Generates a string from this date with the user's current callendar settings.
 *
 *	@param			timeStyle
 *					The format of the time component.
 *
 *	@param			dateStyle
 *					The format of the date component.
 *
 *	@result			A new autoreleased string.
 */
- (NSString *) stringWithTimeStyle:(NSDateFormatterStyle)timeStyle
						 dateStyle:(NSDateFormatterStyle)dateStyle;

/*!
 *					Generates a new date from a string with a specific format.
 *
 *	@param			string
 *					The string containing the date.
 *
 *	@param			format
 *					The format you want, following the format patterns Unicode Technical Standard #35:
 *					http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
 *
 *	@result			A new autoreleased date.
 */
+ (NSDate *) dateWithString:(NSString *)string withFormat:(NSString *)format;

/*!
 *					Generates a new date from a string with the user's current callendar settings.
 *
 *	@param			string
 *					The string containing the date.
 *
 *	@param			timeStyle
 *					The format of the time component.
 *
 *	@param			dateStyle
 *					The format of the date component.
 *
 *	@result			A new autoreleased string.
 */
+ (NSDate *) dateWithString:(NSString *)string
				  timeStyle:(NSDateFormatterStyle)timeStyle
				  dateStyle:(NSDateFormatterStyle)dateStyle;

@end