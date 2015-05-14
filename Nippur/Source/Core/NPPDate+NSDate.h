/*
 *	NPPDate+NSDate.h
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

#import "NPPRuntime.h"

NPP_API NSString *const kNPPDateUniversalNumbers;
NPP_API NSString *const kNPPDateFull;
NPP_API NSString *const kNPPDateShort;
NPP_API NSString *const kNPPDateTime;

/*!
 *					This category is a wrapper to the date object. It brings easy methods to deal with
 *					epoch timestamps, date manipulations and date formats.
 */
@interface NSDate(NPPDate)

- (unsigned int) year;
- (unsigned int) month;
- (unsigned int) day;
- (unsigned int) weekDay; // 1 = Sunday, 7 = Saturday
- (unsigned int) hour;
- (unsigned int) minute;
- (unsigned int) second;

- (NSDate *) dateByAddingHours:(int)hours days:(int)days months:(int)months years:(int)years;
- (NSDate *) nextHour;
- (NSDate *) nextDay;
- (NSDate *) nextMonth;
- (NSDate *) nextYear;

// UTC timezone.
- (NSString *) stringWithFormat:(NSString *)format;
+ (NSString *) stringFromDate:(NSDate *)date withFormat:(NSString *)format;
+ (NSDate *) dateFromString:(NSString *)string withFormat:(NSString *)format;

// Localized methods (using user's callendar).
+ (NSString *) stringFromEpoch:(NSTimeInterval)epoch
					 timeStyle:(NSDateFormatterStyle)timeStyle
					 dateStyle:(NSDateFormatterStyle)dateStyle;
+ (NSString *) stringFromDate:(NSDate *)date
					timeStyle:(NSDateFormatterStyle)timeStyle
					dateStyle:(NSDateFormatterStyle)dateStyle;
+ (NSDate *) dateFromString:(NSString *)string
				  timeStyle:(NSDateFormatterStyle)timeStyle
				  dateStyle:(NSDateFormatterStyle)dateStyle;

@end