/*
 *	NPPDate+NSDate.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 4/20/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPRuntime.h"

NPP_API NSString *const kNPPDateUniversalNumbers;
NPP_API NSString *const kNPPDateFull;
NPP_API NSString *const kNPPDateShort;
NPP_API NSString *const kNPPDateTime;

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