/*
 *	NPPPluginDate.m
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

#import "NPPPluginDate.h"

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
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

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

#pragma mark -
#pragma mark Categories
#pragma mark -
//**********************************************************************************************************
//
//	Categories
//
//**********************************************************************************************************

@implementation NSDate (NPPView)

#pragma mark -
#pragma mark Properties
//**************************************************
//	Properties
//**************************************************

- (unsigned int) year
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:self];
	
	return (unsigned int)[components year];
}

- (unsigned int) month
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	NSDateComponents *components = [calendar components:NSCalendarUnitMonth fromDate:self];
	
	return (unsigned int)[components month];
}

- (unsigned int) day
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:self];
	
	return (unsigned int)[components day];
}

- (unsigned int) weekDay
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:self];
	
	return (unsigned int)[components weekday];
}

- (unsigned int) hour
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	NSDateComponents *components = [calendar components:NSCalendarUnitHour fromDate:self];
	
	return (unsigned int)[components hour];
}

- (unsigned int) minute
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:self];
	
	return (unsigned int)[components minute];
}

- (unsigned int) second
{
	NSDateComponents *components = nil;
	NSCalendar *calendar = [NSCalendar currentCalendar];
	
	calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	components = [calendar components:NSCalendarUnitSecond fromDate:self];
	
	return (unsigned int)[components second];
}

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

- (NSDate *) nextMinute
{
	return [self dateByAddingMinutes:1 hours:0 days:0 months:0 years:0];
}

- (NSDate *) nextHour
{
	return [self dateByAddingMinutes:0 hours:1 days:0 months:0 years:0];
}

- (NSDate *) nextDay
{
	return [self dateByAddingMinutes:0 hours:0 days:1 months:0 years:0];
}

- (NSDate *) nextMonth
{
	return [self dateByAddingMinutes:0 hours:0 days:0 months:1 years:0];
}

- (NSDate *) nextYear
{
	return [self dateByAddingMinutes:0 hours:0 days:0 months:0 years:1];
}

- (NSDate *) dateByAddingMinutes:(int)minutes
						   hours:(int)hours
							days:(int)days
						  months:(int)months
						   years:(int)years
{
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *newDate = nil;
	
	dateComponents.minute = minutes;
	dateComponents.hour = hours;
	dateComponents.day = days;
	dateComponents.month = months;
	dateComponents.year = years;
	calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	newDate = [calendar dateByAddingComponents:dateComponents toDate:self options:0];
	
	nppRelease(dateComponents);
	
	return newDate;
}

- (NSString *) stringWithFormat:(NSString *)format
{
	NSString *string = nil;
	
	// Converting date.
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	dateFormatter.dateFormat = format;
	dateFormatter.timeZone = timeZone;
	string = [dateFormatter stringFromDate:self];
	
	nppRelease(dateFormatter);
	
	return string;
}

- (NSString *) stringWithTimeStyle:(NSDateFormatterStyle)timeStyle
						 dateStyle:(NSDateFormatterStyle)dateStyle
{
	NSString *string = nil;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	dateFormatter.timeStyle = timeStyle;
	dateFormatter.dateStyle = dateStyle;
	string = [dateFormatter stringFromDate:self];
	
	nppRelease(dateFormatter);
	
	return string;
}

+ (NSDate *) dateWithString:(NSString *)string withFormat:(NSString *)format
{
	NSDate *date = nil;
	
	// Converting date.
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	dateFormatter.dateFormat = format;
	dateFormatter.timeZone = timeZone;
	date = [dateFormatter dateFromString:string];
	
	nppRelease(dateFormatter);
	
	return date;
}

+ (NSDate *) dateWithString:(NSString *)string
				  timeStyle:(NSDateFormatterStyle)timeStyle
				  dateStyle:(NSDateFormatterStyle)dateStyle
{
	NSDate *date = nil;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	
	dateFormatter.timeStyle = timeStyle;
	dateFormatter.dateStyle = dateStyle;
	date = [dateFormatter dateFromString:string];
	
	nppRelease(dateFormatter);
	
	return date;
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************


@end