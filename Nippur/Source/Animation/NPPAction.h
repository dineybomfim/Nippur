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
 *					The usual time for animations.
 */
static const float kNPPAnimTime = 0.3f;

/*!
 *					The double of the usual time for animations.
 */
static const float kNPPAnimTimeX2 = 0.6f;

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
 *					This category gives #NPPAction# the ability to be a class cluster, generating instances
 *					using abstract factory design pattern.
 */
@interface NPPAction(NPPActions)

/*!
 *					Interpolation action, by using a constant value in N seconds.
 *
 *	@param			key
 *					The keypath (using KVC) for the property value you want to animate.
 *
 *	@param			byValue
 *					The constant value that will be used in every cycle.
 *
 *	@param			seconds
 *					The time of the animation in seconds.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) moveKey:(NSString *)key by:(float)byValue duration:(float)seconds;

/*!
 *					Interpolation action, to a final value in N seconds.
 *
 *	@param			key
 *					The keypath (using KVC) for the property value you want to animate.
 *
 *	@param			byValue
 *					The constant value that will be used in every cycle.
 *
 *	@param			seconds
 *					The time of the animation in seconds.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) moveKey:(NSString *)key to:(float)toValue duration:(float)seconds;

/*!
 *					Interpolation action, from a value to the current value in N seconds.
 *
 *	@param			key
 *					The keypath (using KVC) for the property value you want to animate.
 *
 *	@param			byValue
 *					The constant value that will be used in every cycle.
 *
 *	@param			seconds
 *					The time of the animation in seconds.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) moveKey:(NSString *)key from:(float)fromValue duration:(float)seconds;

/*!
 *					Interpolation action, from a value to a specified value in N seconds.
 *
 *	@param			key
 *					The keypath (using KVC) for the property value you want to animate.
 *
 *	@param			byValue
 *					The constant value that will be used in every cycle.
 *
 *	@param			seconds
 *					The time of the animation in seconds.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) moveKey:(NSString *)key from:(float)fromValue to:(float)toValue duration:(float)seconds;

/*!
 *					Utils action, it makes a fade-in (alpha property to 1.0).
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) fadeIn;

/*!
 *					Utils action, it makes a fade-in (alpha property to 1.0) and
 *					sets the hidden property to NO.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) fadeInUnhiding;

/*!
 *					Utils action, it makes a fade-out (alpha property to 0.0).
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) fadeOut;

/*!
 *					Utils action, it makes a fade-out (alpha property to 0.0) and
 *					sets the hidden property to YES.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) fadeOutHiding;

/*!
 *					Utils action, it makes a fade-out (alpha property to 0.0) and
 *					removes the object from its superview (safely, if it's a view).
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) fadeOutRemoving;

/*!
 *					Utils action, it just waits for N seconds.
 *
 *	@param			seconds
 *					The time to wait in seconds.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) waitForDuration:(float)seconds;

/*!
 *					Utils action, it removes the object from its superview (safely, if it's a view).
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) removeFromSuperview;

/*!
 *					Utils action, it hides or unhides a view.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) toggleHidden;

/*!
 *					Utils action, it hides a view.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) hide;

/*!
 *					Utils action, it unhides a view.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) unhide;

/*!
 *					Utils action, it runs a block.
 *
 *	@param			block
 *					The block to be executed in this action.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) runBlock:(NPPBlockVoid)block;

/*!
 *					Utils action, it performs a selector on a target.
 *
 *	@param			selector
 *					The selector to be performed.
 *
 *	@param			target
 *					The target in which the selector will be performed.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) performSelector:(SEL)selector onTarget:(id)target;

/*!
 *					Compound action, this action can repeat another action X times.
 *
 *	@param			action
 *					An #NPPAction# to be repeated.
 *
 *	@param			count
 *					The number of times that this action will repeat.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) repeatAction:(NPPAction *)action count:(unsigned int)count;

/*!
 *					Compound action, this action can repeat another action forever.
 *
 *	@param			action
 *					An #NPPAction# to be repeated forever.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) repeatActionForever:(NPPAction *)action;

/*!
 *					Compound action, it encapsulates other actions in sequence,
 *					respecting their #finalDuration#.
 *
 *	@param			actions
 *					An array with the actions in sequence.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) sequence:(NSArray *)actions;

/*!
 *					Compound action, it encapsulates other actions in group, executing all of them at the
 *					same time.
 *
 *	@param			actions
 *					An array with the actions to be a group.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) group:(NSArray *)actions;

/*!
 *					Custom action, you can create your own action if none of the pre-sets fits for you.
 *					In order to do that, just create a #NPPBlockAction#. This block will be called at
 *					every animation cycle (by default 60 fps).
 *
 *	@param			seconds
 *					The duration of your custom action.
 *
 *	@param			block
 *					The events, commands or anything that your custom action does in a single cycle.
 *
 *	@result			An autoreleased action.
 */
+ (NPPAction *) customActionWithDuration:(float)seconds actionBlock:(NPPBlockAction)block;

@end

/*!
 *					This category is the starting point for every action.
 *					Each object has now the ability to be a small piece of action's engine. Each action runs
 *					inside its engine, which means the same action can be reused in various target without
 *					any conflict.
 */
@interface NSObject(NPPActions)

/*!
 *					Runs an action.
 */
- (void) runAction:(NPPAction *)action;

/*!
 *					Runs an action and performs a block and the action ends.
 *
 *	@param			block
 *					A block to be performed at the end of the action.
 */
- (void) runAction:(NPPAction *)action completion:(NPPBlockVoid)block;

/*!
 *					Runs an action and sets a key for it.
 *
 *	@param			key
 *					A string as the key for the action.
 */
- (void) runAction:(NPPAction *)action withKey:(NSString *)key;

/*!
 *					Runs an action with a delay in seconds.
 *
 *	@param			seconds
 *					The delay in seconds.
 */
- (void) runAction:(NPPAction *)action withDelay:(float)seconds;

/*!
 *					Execute an action once in its last stage.
 *
 *	@param			action
 *					The action to be executed.
 */
- (void) executeAction:(NPPAction *)action;

/*!
 *					Checks if this object contains any on going action.
 *
 *	@result			A Bool value indicating if there is actions inside.
 */
- (BOOL) hasActions;

/*!
 *					Retrieves an action with a specified key.
 *
 *	@param			key
 *					A string as the key for the action.
 *
 *	@result			An action for the specified key.
 */
- (NPPAction *) actionForKey:(NSString *)key;

/*!
 *					Removes an action with a specified key. Removing an action immediately interrupts the
 *					action and does not call the completion blocks.
 *
 *	@param			key
 *					A string as the key for the action.
 */
- (void) removeActionForKey:(NSString *)key;

/*!
 *					Removes all actions. Removing an action immediately interrupts the
 *					action and does not call the completion blocks.
 */
- (void) removeAllActions;

@end