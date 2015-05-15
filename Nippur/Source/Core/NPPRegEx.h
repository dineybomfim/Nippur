/*
 *	NPPRegEx.h
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

/*!
 *					Defines option flags to a regular expression function.
 *
 *						- G (Global): More than one match can occur, the RegEx will stop only in the end;
 *						- D (Dotall): Allow . (dot) to match any character, including line separators;
 *						- M (Multiline): Allow ^ and $ to match the start and end of lines;
 *						- I (Ignore Case): Upper and lower case are treat without distinction.
 *
 *	@var			NPPRegExFlagGDM
 *					Represents Global, Dotall and Multiline.
 *	
 *	@var			NPPRegExFlagGDMI
 *					Represents Global, Dotall, Multiline and Ignore Case.
 */
typedef NS_OPTIONS(NSUInteger, NPPRegExFlag)
{
	NPPRegExFlagGDM = 1 << 3 | 1 << 4,
	NPPRegExFlagGDMI = 1 << 0 | 1 << 3 | 1 << 4,
};

/*!
 *					Matches a regular expression against a string. If no match found, this function will
 *					return NO, if one or more matches is found, then this function will return YES.
 *	
 *	@param			original
 *					The original string.
 *
 *	@param			regex
 *					The regular expression to perform replacements.
 *
 *	@param			flag
 *					The regular expression options flags.
 *
 *	@result			A BOOL data type indicating if the regular expression found any match.
 */
NPP_API BOOL nppRegExMatch(NSString *original, NSString *regex, NPPRegExFlag flag);

/*!
 *					Act as nppRegExMatch, but within a specific range.
 *	
 *	@param			original
 *					The original string.
 *
 *	@param			regex
 *					The regular expression to perform replacements.
 *
 *	@param			range
 *					A NSRange representing the range to execute the RegEx.
 *
 *	@param			flag
 *					The regular expression options flags.
 *
 *	@result			A BOOL data type indicating if the regular expression found any match.
 */
NPP_API BOOL nppRegExMatchInRange(NSString *original, NSString *regex, NSRange range, NPPRegExFlag flag);

/*!
 *					Matches a regular expression against a string and return the range of the first match.
 *					If no match found, this function will return {NSNotFound, 0}, if one or more matches
 *					is found, then this function will return its range.
 *
 *	@param			original
 *					The original string.
 *
 *	@param			regex
 *					The regular expression to perform replacements.
 *
 *	@param			flag
 *					The regular expression options flags.
 *
 *	@result			A BOOL data type indicating if the regular expression found any match.
 */
NPP_API NSRange nppRegExRangeOfMatch(NSString *original, NSString *regex, NPPRegExFlag flag);

/*!
 *					Act as nppRegExRangeOfMatch, but within a specific range.
 *
 *	@param			original
 *					The original string.
 *
 *	@param			regex
 *					The regular expression to perform replacements.
 *
 *	@param			range
 *					A NSRange representing the range to execute the RegEx.
 *
 *	@param			flag
 *					The regular expression options flags.
 *
 *	@result			A BOOL data type indicating if the regular expression found any match.
 */
NPP_API NSRange nppRegExRangeOfMatchInRange(NSString *original,
											NSString *regex,
											NSRange range,
											NPPRegExFlag flag);

/*!
 *					Searches and replace a string by using regular expression.
 *	
 *	@param			original
 *					The original string.
 *
 *	@param			regex
 *					The regular expression to perform replacements.
 *
 *	@param			pattern
 *					The pattern (conforming to regular expression patterns) that will replace the matched
 *					regex.
 *
 *	@param			flag
 *					The regular expression options flags.
 *
 *	@result			The resulting NSString. This string is an auto-released instance.
 */
NPP_API NSString *nppRegExReplace(NSString *original,
								  NSString *regex,
								  NSString *pattern,
								  NPPRegExFlag flag);

/*!
 *					Act as nppRegExReplace, but within a specific range.
 *	
 *	@param			original
 *					The original string.
 *
 *	@param			regex
 *					The regular expression to perform replacements.
 *
 *	@param			pattern
 *					The pattern (conforming to regular expression patterns) that will replace the matched
 *					regex.
 *
 *	@param			range
 *					A NSRange representing the range to execute the RegEx.
 *
 *	@param			flag
 *					The regular expression options flags.
 *
 *	@result			The resulting NSString. This string is an auto-released instance.
 */
NPP_API NSString *nppRegExReplaceInRange(NSString *original,
										 NSString *regex,
										 NSString *pattern,
										 NSRange range,
										 NPPRegExFlag flag);

/*!
 *					Validates an email string.
 *	
 *	@param			email
 *					The email string to validate.
 *
 *	@result			A BOOL data type indicating if the email is valid or not.
 */
NPP_API BOOL nppValidateEmail(NSString *email);

/*!
 *					Validates a CPF string.
 *	
 *	@param			cpf
 *					The CPF string to validate. It can be in any format, containing dots and dashes or not.
 *
 *	@result			A BOOL data type indicating if the CPF is valid or not.
 */
NPP_API BOOL nppValidateCPF(NSString *cpf);
