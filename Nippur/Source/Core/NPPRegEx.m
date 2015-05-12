/*
 *	NPPRegExp.m
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

#import "NPPRegEx.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kNPPREGEX_CPF				@"\\.|\\-"
#define kNPPREGEX_EMAIL				@"\\b[\\w\\.-_]+@[\\w\\.\\-\\_]+\\.\\w{2,4}\\b"

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static NSRegularExpression *nppRegEx(NSString *pattern, NPPRegExFlag flag)
{
	NSRegularExpression *reg;
	
	// Creates the RegExp.
	reg = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSUInteger)flag error:nil];
	
	return reg;
}

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

BOOL nppRegExMatch(NSString *original, NSString *regex, NPPRegExFlag flag)
{
	return nppRegExMatchInRange(original, regex, NSMakeRange(0, [original length]), flag);
}

BOOL nppRegExMatchInRange(NSString *original, NSString *regex, NSRange range, NPPRegExFlag flag)
{
	if (original == nil || regex == nil)
	{
		return NO;
	}
	
	NSRegularExpression *reg = nppRegEx(regex, flag);
	NSUInteger matches = [reg numberOfMatchesInString:original
											  options:NSMatchingReportCompletion
												range:range];
	
	return (matches > 0);
}

NSRange nppRegExRangeOfMatch(NSString *original, NSString *regex, NPPRegExFlag flag)
{
	return nppRegExRangeOfMatchInRange(original, regex, NSMakeRange(0, [original length]), flag);
}

NSRange nppRegExRangeOfMatchInRange(NSString *original, NSString *regex, NSRange range, NPPRegExFlag flag)
{
	NSRange result = { NSNotFound, 0 };
	
	if (original == nil || regex == nil)
	{
		return result;
	}
	
	NSRegularExpression *reg = nppRegEx(regex, flag);
	result = [reg rangeOfFirstMatchInString:original
									options:NSMatchingReportCompletion
									  range:range];
	
	return result;
}

NSString *nppRegExReplace(NSString *original, NSString *regex, NSString *pattern, NPPRegExFlag flag)
{
	return nppRegExReplaceInRange(original, regex, pattern, NSMakeRange(0, [original length]), flag);
}

NSString *nppRegExReplaceInRange(NSString *original,
							  NSString *regex,
							  NSString *pattern,
							  NSRange range,
							  NPPRegExFlag flag)
{
	if (original == nil || regex == nil)
	{
		return nil;
	}
	
	NSRegularExpression *reg = nppRegEx(regex, flag);
	NSString *result = [reg stringByReplacingMatchesInString:original
													 options:NSMatchingReportCompletion
													   range:range
												withTemplate:pattern];
	
	return result;
}

BOOL nppValidateEmail(NSString *email)
{
	return nppRegExMatch(email, kNPPREGEX_EMAIL, NPPRegExFlagGDMI);
}

BOOL nppValidateCPF(NSString *cpf)
{
	cpf = nppRegExReplace(cpf, kNPPREGEX_CPF, @"", NPPRegExFlagGDM);
	
	unsigned int sum;
	unsigned int result;
	unsigned int cpfValue[11];
	
	BOOL equalNumber = YES;
	
	unsigned int i;
	unsigned int length = (unsigned int)cpf.length;
	
	if (length < 11)
	{
		return NO;
	}
	
	//*************************
	//	Array of Digits
	//*************************
	for (i = 0; i < length; ++i)
	{
		cpfValue[i] = [[cpf substringWithRange:NSMakeRange(i, 1)] intValue];
	}
	
	//*************************
	//	Redundant Check
	//*************************
	for (i = 0; i < length - 1; ++i)
	{
		if (cpfValue[i] != cpfValue[i + 1])
		{
			equalNumber = NO;
			break;
		}
	}
	
	if (!equalNumber)
	{
		//*************************
		//	First Check
		//*************************
		sum = 0;
		for (i = 10; i > 1; --i)
		{
			sum += cpfValue[10 - i] * i;
		}
		
		result = sum % 11 < 2 ? 0 : 11 - sum % 11;
		if (result != cpfValue[9])
		{
			return NO;
		}
		
		//*************************
		//	Second Check
		//*************************
		sum = 0;
		for (i = 11; i > 1; --i)
		{
			sum += cpfValue[11 - i] * i;
		}
		
		result = sum % 11 < 2 ? 0 : 11 - sum % 11;
		if (result != cpfValue[10])
		{
			return NO;
		}
		
		return YES;
	}
	
	return NO;
}