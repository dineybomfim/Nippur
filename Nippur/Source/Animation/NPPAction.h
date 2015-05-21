/*
 *	NPPAction.h
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

@class NPPAction;

/*!
 *					Defines the easing function of the interpolation. Specific for Move action types.
 *
 *	@var			NPPActionEaseLinear
 *	@var			NPPActionEaseSmoothIn
 *	@var			NPPActionEaseSmoothOut
 *	@var			NPPActionEaseSmoothInOut
 *	@var			NPPActionEaseStrongIn
 *	@var			NPPActionEaseStrongOut
 *	@var			NPPActionEaseStrongInOut
 *	@var			NPPActionEaseElasticIn
 *	@var			NPPActionEaseElasticOut
 *	@var			NPPActionEaseElasticInOut
 *	@var			NPPActionEaseBounceIn
 *	@var			NPPActionEaseBounceOut
 *	@var			NPPActionEaseBounceInOut
 *	@var			NPPActionEaseBackIn
 *	@var			NPPActionEaseBackOut
 *	@var			NPPActionEaseBackInOut
 */
typedef NS_OPTIONS(NSUInteger, NPPActionEase)
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
};

/*!
 *					This block is called by the Action API over time, accordingly to the ease function.
 *
 *	@param			currentTarget
 *					The object associated with this action.
 *
 *	@param			elapsedTime
 *					The elapsed time since the beginning of this action.
 *
 *	@param			token
 *					A unique ID used to manage action and subactions.
 */
typedef void (^NPPBlockAction)(id currentTarget, float elapsedTime, double token);

/*!
 *					TODO (exposed).
 */
typedef struct
{
	float speed;
	float duration;
	float finalDuration;
} NPPActionTime;

/*!
 *					TODO (exposed).
 */
static const NPPActionTime kNPPActionTimeZero = (NPPActionTime){ 1.0f, 0.0, 0.0f };

/*!
 *					TODO (exposed).
 */
static inline double nppGetActionToken(void)
{
	return nppApplicationTime();
}

/*!
 *					TODO (exposed).
 */
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

/*!
 *					TODO (exposed).
 */
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
 *					The Action object is the base of the entire Animation API. It's a C approach to deal
 *					with timing functions and ease equations. Actually the actions are much bigger than
 *					animations and can be used to a variety of things, creating a hierarchy of actions over
 *					the time.
 *
 *					NPPAction is a node component of it self and can be used to create a timeline. As a node
 *					and action can have sub-actions, which will respect and inherits its parent rules.
 *
 *					<pre>
 *					                       Timeline with N seconds
 *					    <-------------------------------------------------------->
 *
 *					    +----------------------------------+ +-------+ +---------+
 *					    | +--------------+ +---------+ +-+ | |   A   | | +-----+ |
 *					    | | +-------+    | |    E    | |F| | +-------+ | |  C  | |
 *					    | | |   A   |    | +---------+ +-+ |           | +-----+ |
 *					    | | +-------+    |                 |           | +-+     |
 *					    | | +----------+ |                 |           | |F|     |
 *					    | | |    B     | |                 |           | +-+     |
 *					    | | +----------+ |         G       |           +---------+
 *					    | | +-----+      |                 |
 *					    | | |  C  |   D  |                 |
 *					    | | +-----+      |                 |
 *					    | +--------------+                 |
 *					    +----------------------------------+
 *					</pre>
 *
 *					The above diagram shows that an action can be a group or a sequence of other sub-actions,
 *					which is the principle of a timeline. A Group action will recursively execute all its
 *					nodes simultaneously. A Sequence action will execute all its nodes one by one.
 *
 *					The diagram also shows that as each action is a reusable object, you can reuse them
 *					in many forms. An action first used as a node (sub-action), can be used again in the
 *					timeline or inside another action.
 *
 *					There are actions to reverse another action, to repeat, to execute a block, perform
 *					another action and more.
 *
 *					The #NPPAction# is a class cluster pattern, which means the basic action types will
 *					be generated and handled internally. But you can also create your own custom action.
 */
@interface NPPAction : NSObject <NSCopying, NSCoding>
{
@protected
	NPPBlockAction				_actionBlock;
	NPPActionTime				_time;
	NPPActionEase				_ease;
}

/*!
 *					The base of all actions. Inside this block each action can perform its tasks.
 *					When creating a custom action, you must set the action block by your self, performing
 *					the tasks you want inside this block.
 */
@property (nonatomic, NPP_COPY) NPPBlockAction actionBlock;

/*!
 *					The animation's duration in seconds. The default value is NPPActionEaseLinear.
 */
@property (nonatomic) NPPActionEase ease;

/*!
 *					The speed changes how the time is handled. The default value is 1.0.
 */
@property (nonatomic) float speed;

/*!
 *					The duration in seconds.
 */
@property (nonatomic) float duration;

/*!
 *					The special value to instruct the parent nodes about total duration.
 *					If not overridden, returns the duration value.
 */
@property (nonatomic, readonly) float finalDuration;

/*!
 *					Returns the reserved version of this action.
 *					The possibilities are:
 *						- Block = Same;
 *						- Group = All reversed;
 *						- Move = Reverse (attention for TO behavior);
 *						- Repeat = Reversed action;
 *						- Selector = Same;
 *						- Sequence = Opposite order with all reversed;
 *						- Custom = Inherits;
 *
 *	@result			An autoreleased instance.
 */
- (NPPAction *) reversed;

/*!
 *					Save this action into a file, in the private framework folder.
 *					The rules are:
 *						- Block = Doesn't save;
 *						- Selector = The target must conforms to NSCoding;
 *						- Custom = Inherits;
 *
 *	@param			fileName
 *					The file's name.
 */
- (void) saveToFile:(NSString *)fileName;

/*!
 *					Loads a previously saved action.
 *
 *	@param			fileName
 *					The file's name.
 *
 *	@result			An autoreleased instance.
 */
+ (NPPAction *) actionFromFile:(NSString *)fileName;

/*!
 *					Changes the default ease property for all new actions.
 *
 *	@param			ease
 *					The new default ease mode.
 */
+ (void) defineEasingMode:(NPPActionEase)ease;

@end

/*!
 *					This category give #NPPAction# the ability to be a class cluster and generate instances
 *					using a factory method.
 */
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

/*!
 *					This category is the starting point for every action.
 *					Each object has now the ability to be a small piece of action's engine. Each action runs
 *					inside its engine, which means the same action can be reused in various target without
 *					any conflict.
 */
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