/*
 *	NPPFunctions.m
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 8/15/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NPPFunctions.h"

#pragma mark -
#pragma mark Constants
#pragma mark -
//**********************************************************************************************************
//
//	Constants
//
//**********************************************************************************************************

// Beta default string.
#define NPP_STR_BETA				@"beta"

// Bundle stuff.
#define NPP_STR_NIB					@".nib"
#define NPP_STR_BUNDLE				@"bundle"
#define NPP_LOCALIZED				@"Localizable"
#define NPP_BUNDLE_VERSION			@"CFBundleShortVersionString"
#define NPP_BUNDLE_BUILD			@"CFBundleVersion"
#define NPP_BUNDLE_NAME				@"CFBundleName"
#define NPP_BUNDLE_DISPLAY			@"CFBundleDisplayName"
#define NPP_BUNDLE_IDENTIFIER		@"CFBundleIdentifier"

#define kNPPREGEX_UDID				@"(.{8})(.{4})(.{4})(.{4})(.{12})"
#define kNPPREGEX_DASH				@"\\-"

#pragma mark -
#pragma mark Private Interface
#pragma mark -
//**********************************************************************************************************
//
//	Private Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Private Definitions
//**************************************************
//	Private Definitions
//**************************************************

static NSString			*_defaultBetaString		= nil;
static int				_defaultBetaCheck		= -1;

#pragma mark -
#pragma mark Private Functions
//**************************************************
//	Private Functions
//**************************************************

static NSBundle *nppGetBundle(void)
{
	static NSBundle *_nppBundle = nil;
	
	if (_nppBundle == nil)
	{
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource:NPP_NAME ofType:NPP_STR_BUNDLE];
		_nppBundle = [[NSBundle alloc] initWithPath:bundlePath];
	}
	
	return _nppBundle;
}

static NSMutableString *nppGetLocalized(void)
{
	static NSMutableString *_nppLocalized = nil;
	
	if (_nppLocalized == nil)
	{
		_nppLocalized = [[NSMutableString alloc] initWithString:NPP_LOCALIZED];
	}
	
	return _nppLocalized;
}

#pragma mark -
#pragma mark Public Interface
#pragma mark -
//**********************************************************************************************************
//
//	Public Interface
//
//**********************************************************************************************************

#pragma mark -
#pragma mark Public Functions
//**************************************************
//	Public Functions
//**************************************************

float nppRandomf(float min, float max)
{
	return min + ((double)arc4random() / NPP_ARC4RANDOM_MAX) * (max - min);
}

int nppRandomi(int min, int max)
{
	unsigned int random = arc4random_uniform(++max);
	return min + random;
}

NSString *nppS(NSString *string)
{
	return [[NSBundle mainBundle] localizedStringForKey:string value:@"" table:nppGetLocalized()];
}

void nppSetS(NSString *localizedName)
{
	NSMutableString *localized = nppGetLocalized();
	[localized setString:localizedName];
}

NSString *nppGetFile(NSString *named)
{
	NSRange range;
	
	// Prevent Microsoft Windows path file format.
	named = [named stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
	
	range = [named rangeOfString:@"/" options:NSBackwardsSearch];
	
	if (range.length > 0)
	{
		named = [named substringFromIndex:range.location + 1];
	}
	
	return named;
}

NSString *nppGetFileExtension(NSString *named)
{
	NSRange range;
	NSString *type = @"";
	
	// Isolates the file extension.
	range = [named rangeOfString:@"." options:NSBackwardsSearch];
	
	if (range.length > 0)
	{
		type = [named substringFromIndex:range.location + 1];
	}
	
	return type;
}

NSString *nppGetFileName(NSString *named)
{
	NSRange range;
	
	// Gets the file name + extension.
	named = nppGetFile(named);
	
	// Using range and substringToIndex: is around 70% faster than stringByDeletingPathExtension: method
	range = [named rangeOfString:@"." options:NSBackwardsSearch];
	
	if (range.length > 0)
	{
		named = [named substringToIndex:range.location];
	}
	
	return named;
}

NSString *nppGetPath(NSString *named)
{
	NSString *pathOnly = nil;
	NSRange range = [named rangeOfString:nppGetFile(named)];
	
	// Checks if the path contains a file at the end to extract it, if necessary.
	if (range.length > 0)
	{
		pathOnly = [named substringToIndex:range.location];
	}
	
	return pathOnly;
}

NSString *nppMakePath(NSString *named)
{
	NSString *path = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Prevent Microsoft Windows path files.
	named = [named stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
	
	// Assuming the path already contains the file path, checks if the file exist,
	// in afirmative case use it, otherwise, uses the default file path.
	if ([fileManager fileExistsAtPath:named])
	{
		path = named;
	}
	else if (named != nil)
	{
		// Default bundle.
		path = [[nppGetBundle() bundlePath] stringByAppendingPathComponent:named];
		
		// Application main bundle.
		if (![fileManager fileExistsAtPath:path])
		{
			path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:nppGetFile(named)];
		}
	}
	
	return path;
}

NSURL *nppMakeURL(NSString *named)
{
	NSURL *url = nil;
	NSRange range = [named rangeOfString:@"://"];
	
	if (range.length > 0)
	{
		url = [NSURL URLWithString:nppMakePath(named)];
	}
	
	if (url == nil)
	{
		url = [[NSBundle mainBundle] URLForResource:nppGetFileName(named)
									  withExtension:nppGetFileExtension(named)];
	}
	
	return url;
}

NSString *nppStringFromFile(NSString *named)
{
	return [NSString stringWithContentsOfFile:nppMakePath(named) encoding:NSUTF8StringEncoding error:nil];
}

NSData *nppDataFromFile(NSString *named)
{
	return [NSData dataWithContentsOfFile:nppMakePath(named)];
}

id nppItemFromXIB(NSString *name)
{
	id returningItem = nil;
	id item;
	Class classObject = NSClassFromString(name);
	
	if (nppFileExists([name stringByAppendingString:NPP_STR_NIB]))
	{
		NSArray *array = [[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil];
		
		for (item in array)
		{
			if ([item isKindOfClass:classObject])
			{
				returningItem = item;
				break;
			}
		}
	}
	
	return returningItem;
}

BOOL nppFileExists(NSString *named)
{
	return [[NSFileManager defaultManager] fileExistsAtPath:nppMakePath(named)];
}

float nppPointsDistance(CGPoint pointA, CGPoint pointB)
{
	double xDistace = fabs(pointA.x - pointB.x);
	double yDistance = fabs(pointA.y - pointB.y);
	
	return sqrtf(xDistace * xDistace + yDistance * yDistance);
}

//#define NPPLineSlope(p1,p2)			(((p2).y - (p1).y) / ((p2).x - (p1).x))
//#define NPPLineIntercept(p,slope)	((p).y - (slope) * (p).x)
//
//static void nppRoutePoint()
//{
//	CGPoint p1 = { 1, 1 };
//	CGPoint p2 = { 5, 25 };
//	CGPoint point = { 3, 7 };
//	
//	double slope = NPPLineSlope(p1, p2);
//	double intercept = NPPLineIntercept(p1, slope);
//	
//	double verify = slope * point.x + intercept;
//	double distance = fabsf(verify - point.y);
//	
//	if (verify > (point.y - 0.01) && verify < (point.y + 0.01))
//    {
//		printf("Given point lies on the line\n");
//    }
//}

void nppPerformAction(id target, SEL action)
{
	if ([target respondsToSelector:action])
	{
		// Starting at Xcode 4.4, the compiler still showing warnings when using "performSelector"
		// with ARC without declaring its relationship with its holder.
		((id (*)(id, SEL))objc_msgSend)(target, action);
	}
}

NSString *nppGetApplicationVersion(void)
{
	static NSString *_default = nil;
	
	if (_default == nil)
	{
		_default = [[NSBundle mainBundle] objectForInfoDictionaryKey:NPP_BUNDLE_VERSION];
		nppRetain(_default);
	}
	
	return _default;
}

NSString *nppGetApplicationBuild(void)
{
	static NSString *_default = nil;
	
	if (_default == nil)
	{
		_default = [[NSBundle mainBundle] objectForInfoDictionaryKey:NPP_BUNDLE_BUILD];
		nppRetain(_default);
	}
	
	return _default;
}

NSString *nppGetApplicationName(void)
{
	static NSString *_default = nil;
	
	if (_default == nil)
	{
		_default = [[NSBundle mainBundle] objectForInfoDictionaryKey:NPP_BUNDLE_NAME];
		_default = _default ? : [[NSBundle mainBundle] objectForInfoDictionaryKey:NPP_BUNDLE_DISPLAY];
		nppRetain(_default);
	}
	
	return _default;
}

NSString *nppGetApplicationBundleID(void)
{
	static NSString *_default = nil;
	
	if (_default == nil)
	{
		_default = [[NSBundle mainBundle] objectForInfoDictionaryKey:NPP_BUNDLE_IDENTIFIER];
		nppRetain(_default);
	}
	
	return _default;
}

NSString *nppGetLanguage(void)
{
	NSString *language = [[NSLocale preferredLanguages] firstObject];
	NSString *languageCountry = [[NSLocale autoupdatingCurrentLocale] objectForKey:NSLocaleCountryCode];
	
	if (!nppRegExMatch(language, kNPPREGEX_DASH, NPPRegExFlagGDMI))
	{
		language = [language stringByAppendingFormat:@"-%@", languageCountry];
	}
	
	return language;
}

id nppGetBundleObject(NSString *name)
{
	id object = nil;
	Class classObject = NSClassFromString(name);
	
	if (nppFileExists([name stringByAppendingString:NPP_STR_NIB]))
	{
		NSArray *array = [[NSBundle mainBundle] loadNibNamed:name owner:nil options:nil];
		id item = nil;
		
		for (item in array)
		{
			if ([item isKindOfClass:classObject])
			{
				object = nppRetain(item);
				break;
			}
		}
	}
	
	return nppAutorelease(object);
}

NSString *nppGenerateHash(unsigned int size, BOOL canRepeat, BOOL canUpperCase)
{
	NSMutableString *string = [NSMutableString string];
	NSString *newChar = nil;
	NSString *source = @"0123456789abcdefghijklmnopqrstuvwxyz";
	unsigned int maxLength = 0;
	unsigned int i = 0;
	unsigned int total = 0;
	
	if (canUpperCase)
	{
		source = [source stringByAppendingString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
	}
	
	// Checks for length overflow and truncate if necessary.
	maxLength = (unsigned int)[source length];
	size = (!canRepeat && size > maxLength) ? maxLength : size;
	const char *cSource = [source UTF8String];
	
	// add random characters to $password until $length is reached
	while (total < size)
	{
		// Picking a random char.
		i = nppRandomi(0, maxLength - 1);
		newChar = [NSString stringWithFormat:@"%c", cSource[i]];
		
		// Checks for repeated characters, if necessary.
		if (canRepeat || [string rangeOfString:newChar].length == 0)
		{
			[string appendString:newChar];
			++total;
		}
	}
	
	return string;
}

NSString *nppGenerateUUID(void)
{
	NSString *uuid = nppGenerateHash(32, YES, NO);
	uuid = nppRegExReplace(uuid, kNPPREGEX_UDID, @"$1-$2-$3-$4-$5", NPPRegExFlagGDMI);
	
	return [uuid uppercaseString];
}

void nppSwizzle(Class aClass, SEL old, SEL newer)
{
	Method oldSel = class_getInstanceMethod(aClass, old);
	Method newSel = class_getInstanceMethod(aClass, newer);
	if(class_addMethod(aClass, old, method_getImplementation(newSel), method_getTypeEncoding(newSel)))
	{
		class_replaceMethod(aClass, newer, method_getImplementation(oldSel), method_getTypeEncoding(oldSel));
	}
	else
	{
		method_exchangeImplementations(oldSel, newSel);
	}
}

BOOL nppBetaCheck(void)
{
	// Look at the bundle identifier once, since it can't change during the fly anyway.
	if (_defaultBetaCheck == -1)
	{
		NSString *betaString = (_defaultBetaString != nil) ? _defaultBetaString : NPP_STR_BETA;
		NSString *identifier = nppGetApplicationBundleID();
		NSRange range = [[identifier lowercaseString] rangeOfString:betaString];
		_defaultBetaCheck = (range.length > 0);
	}
	
	return _defaultBetaCheck;
}

void nppBetaSetString(NSString *betaString)
{
	nppRelease(_defaultBetaString);
	_defaultBetaString = [betaString copy];
	
	// Reset the check variable, so it'll check again at next nppBetaCheck call.
	_defaultBetaCheck = -1;
}