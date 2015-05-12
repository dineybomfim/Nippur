/*
 *	NPPAction.h
 *	Nippur
 *
 *	The Nippur is a framework for iOS to make daily work easier and more reusable.
 *	This Nippur contains many API and includes many wrappers to other Apple frameworks.
 *
 *	More information at the official web site: http://db-in.com/nippur
 *
 *	Created by Diney Bomfim on 8/12/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NippurCore.h"

@class NPPAction;

typedef enum
{
	NPPActionEaseLinear,
	NPPActionEaseSmoothIn,
	NPPActionEaseSmoothOut,
	NPPActionEaseSmoothInOut,
	NPPActionEaseStrongIn,
	NPPActionEaseStrongOut,
	NPPActionEaseStrongInOut,
	NPPActionEaseElasticIn,
	NPPActionEaseElasticOut,
	NPPActionEaseElasticInOut,
	NPPActionEaseBounceIn,
	NPPActionEaseBounceOut,
	NPPActionEaseBounceInOut,
	NPPActionEaseBackIn,
	NPPActionEaseBackOut,
	NPPActionEaseBackInOut,
} NPPActionEase;

typedef void (^NPPBlockAction)(id currentTarget, float elapsedTime, double token);



//TODO it's too exposed.

typedef struct
{
	float speed;
	float duration;
	float finalDuration;
} NPPActionTime;

static const NPPActionTime kNPPActionTimeZero = (NPPActionTime){ 1.0f, 0.0, 0.0f };

static inline double nppGetActionToken(void)
{
	return nppApplicationTime();
}

static inline NSString *nppGetCArrayString(void *array, unsigned int count)
{
	/*
	NSString *string = nil;
	char *cString = malloc(0);
	char *cChar = malloc(64 * NPP_SIZE_CHAR);
	double *pointer = (double *)array;
	unsigned int i = 0;
	
	for (i = 0; i < count; ++i)
	{
		sprintf(cChar, "%.16g ", *pointer++);
		nppLog(@"%s %zi", cChar, strlen(cChar));
		strcat(cString, cChar);
	}
	
	string = [NSString stringWithUTF8String:cString];
	
	nppFree(cString);
	nppFree(cChar);
	/*/
	NSMutableString *string = [NSMutableString string];
	unsigned int i = 0;
	double *pointer = (double *)array;
	
	for (i = 0; i < count; ++i)
	{
		[string appendFormat:@"%.16g ", *pointer++];
	}
	//*/
	
	return string;
}

static inline void nppSetCArrayString(NSString *string, void *array)
{
	//*
	const char *cString = [string UTF8String];
	const char *delimiters = " ";
	double *pointer = (double *)array;
	char *token = strtok((char *)cString, delimiters);
	
	while (token != NULL)
	{
		//*pointer++ = atof(token);
		*pointer++ = strtod(token, NULL);
		token = strtok(NULL, delimiters);
	}
	/*/
	NSArray *components = [string componentsSeparatedByString:@" "];
	NSString *value = nil;
	double *pointer = (double *)array;
	
	for (value in components)
	{
		if ([value length] > 0)
		{
			*pointer++ = [value doubleValue];
		}
	}
	//*/
}

/*!
 *					B
 */
@interface NPPAction : NSObject <NSCopying, NSCoding>
{
@protected
	NPPBlockAction				_actionBlock;
	NPPActionTime				_time;
	NPPActionEase				_ease;
}

@property (nonatomic, NPP_COPY) NPPBlockAction actionBlock;

/*!
 *					The animation's duration in seconds.
 */
@property (nonatomic) NPPActionEase ease;
@property (nonatomic) float speed;
@property (nonatomic) float duration;
@property (nonatomic, readonly) float finalDuration;

// Block = Same.
// Group = All reversed.
// Move = Reverse (attention for TO behavior).
// Repeat = Reversed action.
// Selector = Same.
// Sequence = Opposite order with all reversed.
// Custom = Same.
- (NPPAction *) reversed;

// Blocks = Doesn't save.
// Group = Save all.
// Move = Save all.
// Repeat = Save all.
// Selector = Save the selector, but the target just saves if it conforms to NSCoding.
// Sequence = Save all.
// Custom = Doesn't save.
- (void) saveToFile:(NSString *)fileName;
+ (NPPAction *) actionFromFile:(NSString *)fileName;

+ (void) defineEasingMode:(NPPActionEase)ease;

@end

@interface NPPAction(NPPActions)

// Move (KVC)
+ (NPPAction *) moveKey:(NSString *)key by:(float)byValue duration:(float)seconds;
+ (NPPAction *) moveKey:(NSString *)key to:(float)toValue duration:(float)seconds;
+ (NPPAction *) moveKey:(NSString *)key from:(float)fromValue duration:(float)seconds;
+ (NPPAction *) moveKey:(NSString *)key from:(float)fromValue to:(float)toValue duration:(float)seconds;

// Utils
+ (NPPAction *) fadeIn;
+ (NPPAction *) fadeInUnhiding;
+ (NPPAction *) fadeOut;
+ (NPPAction *) fadeOutHiding;
+ (NPPAction *) fadeOutRemoving;
+ (NPPAction *) waitForDuration:(float)seconds;
+ (NPPAction *) removeFromSuperview;
+ (NPPAction *) toggleHidden;
+ (NPPAction *) hide;
+ (NPPAction *) unhide;
+ (NPPAction *) runBlock:(NPPBlockVoid)block;
+ (NPPAction *) performSelector:(SEL)selector onTarget:(id)target;

// Compounds
+ (NPPAction *) repeatAction:(NPPAction *)action count:(unsigned int)count;
+ (NPPAction *) repeatActionForever:(NPPAction *)action;
+ (NPPAction *) sequence:(NSArray *)actions;
+ (NPPAction *) group:(NSArray *)actions;

// Custom
+ (NPPAction *) customActionWithDuration:(float)seconds actionBlock:(NPPBlockAction)block;

@end

@interface NSObject(NPPActions)

- (void) runAction:(NPPAction *)action;
- (void) runAction:(NPPAction *)action completion:(NPPBlockVoid)block;
- (void) runAction:(NPPAction *)action withKey:(NSString *)key;
- (void) runAction:(NPPAction *)action withDelay:(float)seconds;
- (void) executeAction:(NPPAction *)action;

- (BOOL) hasActions;
- (NPPAction *) actionForKey:(NSString *)key;

// Removing does not call completion blocks.
- (void) removeActionForKey:(NSString *)key;
- (void) removeAllActions;

@end