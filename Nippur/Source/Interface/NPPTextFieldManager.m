/*
 *	NPPTextFieldManager.m
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

#import "NPPTextFieldManager.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

#define kNPPREGEX_OFFSET			@".*?offset=(\\d*?)\\D.*"
#define kNPPREGEX_CHAR_FORMAT		@"#|@|\\*"

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

NPP_STATIC_READONLY(getManager, NPPTextFieldManager);

NPP_STATIC_READONLY(getTexts, NSMutableDictionary);

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

@implementation NPPTextFieldManager

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

- (void) updateTextField:(id)sender
{
	UITextField *textField = (UITextField *)sender;
	NSString *format = [getTexts() objectForKey:[NSNumber numberWithUnsignedInt:(unsigned int)sender]];
	
	// Prevent infinity loop.
	[textField removeTarget:getManager()
					 action:@selector(updateTextField:)
		   forControlEvents:UIControlEventEditingChanged];
	
	// TRICK: As is not possible to retrieve the value from the UITextPosition,
	// use RegEx to extract offset value.
	NSString *selected = [textField.selectedTextRange.start description];
	selected = nppRegExReplace(selected, kNPPREGEX_OFFSET, @"$1", NPPRegExFlagGDMI);
	unsigned int selectedStart = [selected intValue];
	
	NSMutableString *formated = [[NSMutableString alloc] init];
	NSString *charString;
	NSString *charFormat;
	NSString *charRegEx;
	
	unsigned int selectedOffset;
	unsigned int offset = 0;
	unsigned int lastChar = 0;
	
	unsigned int textI = 0;
	unsigned int textLength = (unsigned int)textField.text.length;
	
	unsigned int i;
	unsigned int length = (unsigned int)format.length;
	for (i = 0; i < length; ++i)
	{
		// Gets one character from the original format.
		charFormat = [format substringWithRange:NSMakeRange(i, 1)];
		
		// Checks if the character is valid for replace.
		if (nppRegExMatch(charFormat, kNPPREGEX_CHAR_FORMAT, NPPRegExFlagGDMI))
		{
			charString = nil;
			charRegEx = nil;
			
			// Gets each character from the current textfield's text.
			while (textI < textLength)
			{
				charString = [textField.text substringWithRange:NSMakeRange(textI++, 1)];
				
				// Checks if the current character in the format string is number or letter.
				if ([charFormat isEqualToString:@"#"])
				{
					charRegEx = @"\\d";
				}
				else if ([charFormat isEqualToString:@"*"])
				{
					charRegEx = @"[a-z]";
				}
				else if ([charFormat isEqualToString:@"@"])
				{
					charRegEx = @"[a-z]";
					charString = [charString uppercaseString];
				}
				
				// If the current character is subject to change, breaks the loop.
				// By doing so, the current "charString" will not be nil, so it'll be used as "charFormat".
				if (nppRegExMatch(charString, charRegEx, NPPRegExFlagGDMI))
				{
					lastChar = textI;
					break;
				}
				
				charString = nil;
			}
			
			// Sets the current character with the replaced char or the default one.
			charFormat = (charString != nil) ? charString : @"_";
		}
		
		// Place the final character in the formated string.
		[formated appendString:charFormat];
	}
	
	// Sets the textfield's text to the new formated string.
	textField.text = formated;
	
	// Put the text field caret at the correct position.
	if (formated.length > lastChar + offset)
	{
		// Move the caret for the next editable position. However does nothing if:
		// - There is no more editable position.
		// - The user is deleting characters.
		// - The user is editing the middle of the text field.
		NSRange blankRange = [formated rangeOfString:@"_"];
		BOOL valid = (blankRange.length > 0 && textLength >= format.length && selectedStart >= lastChar);
		
		// Besides, force the caret move if the user is start editing now.
		valid = textLength == 1 || valid;
		
		if (valid) 
		{
			offset = (unsigned int)blankRange.location;
		}
		else
		{
			offset = selectedStart;
		}
		
		selectedOffset = offset;
		//*/
		// Move the caret to the final position.
		UITextPosition *start = textField.beginningOfDocument;
		UITextPosition *from = [textField positionFromPosition:start offset:selectedOffset];
		UITextRange *textRange = [textField textRangeFromPosition:from toPosition:from];
		[textField setSelectedTextRange:textRange];
	}
	
	// Rebind the target action.
	[textField addTarget:getManager()
				  action:@selector(updateTextField:)
		forControlEvents:UIControlEventEditingChanged];
	
	nppRelease(formated);
}

#pragma mark -
#pragma mark Self Public Methods
//**************************************************
//	Self Public Methods
//**************************************************

+ (void) setTextField:(UITextField *)textField format:(NSString *)format
{
	textField.placeholder = nppRegExReplace(format, kNPPREGEX_CHAR_FORMAT, @"_", NPPRegExFlagGDMI);
	
	[textField addTarget:getManager()
				  action:@selector(updateTextField:)
		forControlEvents:UIControlEventEditingChanged];
	
	// Uses the memory pointer it self as key.
	[getTexts() setObject:format forKey:[NSNumber numberWithUnsignedInt:(unsigned int)textField]];
}

+ (void) removeTextField:(UITextField *)textField
{
	[textField removeTarget:getManager()
					 action:@selector(updateTextField:)
		   forControlEvents:UIControlEventEditingChanged];
	
	// Uses the memory pointer it self as key.
	[getTexts() removeObjectForKey:[NSNumber numberWithUnsignedInt:(unsigned int)textField]];
}

+ (void) removeAll
{
	[getTexts() removeAllObjects];
}

#pragma mark -
#pragma mark Override Public Methods
//**************************************************
//	Override Public Methods
//**************************************************

- (void) dealloc
{
#ifndef NPP_ARC
	[super dealloc];
#endif
}

+ (BOOL) accessInstanceVariablesDirectly
{
	return NO;
}

@end
