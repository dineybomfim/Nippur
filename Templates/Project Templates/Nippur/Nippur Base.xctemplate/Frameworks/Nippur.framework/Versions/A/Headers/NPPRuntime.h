/*
 *	NPPRuntime.h
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

#import <objc/objc.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
 
#pragma mark -
#pragma mark Basic Definitions
#pragma mark -
//**********************************************************************************************************
//
//	Basic Definitions
//
//**********************************************************************************************************

#pragma mark -
#pragma mark NPP Definitions
//**************************************************
//	NPP Definitions
//**************************************************

// Nippur identification.
#define NPP_NAME					@"Nippur"
#define NPP_VERSION					1.0f

#pragma mark -
#pragma mark iOS Definitions
//**************************************************
//	iOS Definitions
//**************************************************

// Checks for iOS version.
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0

	// Prevents compiling for unsupported versions.
	#error This project only works with iOS 6.0 and later.

#endif

#pragma mark -
#pragma mark Compiler Definitions
//**************************************************
//	Compiler Definitions
//**************************************************

// Defines the debug mode for the simulator.
#if TARGET_IPHONE_SIMULATOR

	// Enables the debug mode only in the simulator.
	#define NPP_SIMULATOR			1

#endif

// Defines the debug mode for the simulator.
#ifdef DEBUG

	// Enables the debug mode only in the simulator.
	#define NPP_DEBUG				1

#endif

// Defines the iOS or Mac OS compilation.
#if TARGET_OS_IPHONE
	#define NPP_IOS					1
#else
	#define NPP_MACOS				1
#endif

// Defines the static functions. The Inline instructions is a little bit more expensive.
#define NPP_INLINE					static inline

// Defines the ARC instructions, ONLY FOR PUBLIC HEADERS.
#if __has_feature(objc_arc)

	// ARC definition.
	#define NPP_ARC

	// Convertion instructions.
	#define NPP_ARC_UNSAFE			__unsafe_unretained
	#define NPP_ARC_BRIDGE			__bridge
	#define NPP_ARC_ASSIGN			__weak
	#define NPP_ARC_RETAIN			__strong

	// Property definitions
	#define NPP_RETAIN				strong
	#define NPP_ASSIGN				weak
	#define NPP_COPY				copy

#else

	// Convertion instructions.
	#define NPP_ARC_UNSAFE
	#define NPP_ARC_BRIDGE
	#define NPP_ARC_ASSIGN
	#define NPP_ARC_RETAIN

	// Property definitions
	#define NPP_RETAIN				retain
	#define NPP_ASSIGN				assign
	#define NPP_COPY				copy

#endif

#pragma mark -
#pragma mark C/C++ Definitions
//**************************************************
//	C/C++ Definitions
//**************************************************

// Defines the C/C++ extern patterns
#ifdef __cplusplus

	// Extern instruction for C++ code.
	#define NPP_API					extern "C" __attribute__((visibility ("default")))

#else

	// Extern instruction for C code.
	#define NPP_API					extern __attribute__((visibility ("default")))

#endif

// Define the basic platform bits. It will change the size of int and long
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64

	#define NPP_64BITS				1

#else

	#define NPP_64BITS				0

#endif

#pragma mark -
#pragma mark Data Type Definitions
#pragma mark -
//**********************************************************************************************************
//
//	Data Type Definitions
//
//**********************************************************************************************************

// Size of basic data types.
#define NPP_SIZE_CGRECT				16
#define NPP_SIZE_CGPOINT			8
#define NPP_SIZE_CGSIZE				8
#define NPP_SIZE_DOUBLE				8
#define NPP_SIZE_LONG_LONG			8
#define NPP_SIZE_ULONG_LONG			8
#if NPP_64BITS
	#define NPP_SIZE_POINTER		8
	#define NPP_SIZE_LONG			8
	#define NPP_SIZE_ULONG			8
#else
	#define NPP_SIZE_POINTER		4
	#define NPP_SIZE_LONG			4
	#define NPP_SIZE_ULONG			4
#endif
#define NPP_SIZE_FLOAT				4
#define NPP_SIZE_INT				4
#define NPP_SIZE_UINT				4
#define NPP_SIZE_SHORT				2
#define NPP_SIZE_USHORT				2
#define NPP_SIZE_CHAR				1
#define NPP_SIZE_UCHAR				1
#define NPP_SIZE_BOOL				1

// Max integer data type values.
#define NPP_MAX_8_HALF				127
#define NPP_MAX_8					255
#define NPP_MAX_16_HALF				32767
#define NPP_MAX_16					65535
#define NPP_MAX_32_HALF				2147483647u
#define NPP_MAX_32					4294967295u
#define NPP_MAX_64_HALF				9223372036854775807ull
#define NPP_MAX_64					18446744073709551615ull

// Max floating point values.
#define NPP_MAX_32F					2147483647.0f
#define NPP_MAX_64D					9223372036854775807.0

// Time.
#define NPP_NSEC					1000000000ull
#define NPP_USEC					1000000ull
#define NPP_MAX_FPS					60.0f
#define NPP_CYCLE					1.0f / NPP_MAX_FPS
#define NPP_CYCLE_USEC				NPP_CYCLE * NPP_USEC
#define NPP_CYCLE_NSEC				NPP_CYCLE * NPP_NSEC

// Invalid data.
#define NPP_BLANK_CHAR				' '
#define NPP_NOT_FOUND				NPP_MAX_32

// Random.
#define NPP_ARC4RANDOM_MAX			0x100000000

// Geometry.
#define kNPP_PI						3.141592f // PI
#define kNPP_2PI					6.283184f // 2 * PI
#define kNPP_PI2					1.570796f // PI / 2
#define kNPP_PI180					0.017453f // PI / 180
#define kNPP_180PI					57.295780f // 180 / PI
#define NPPDegreesToRadians(x)		((x) * kNPP_PI180)
#define NPPRadiansToDegrees(x)		((x) * kNPP_180PI)

#define NPPCirclePerimeter(r)		(2.0f * kNPP_PI * (r))
#define NPPElipsePerimeter(rl,rs)	(2.0f * kNPP_PI * sqrtf((rl) * (rl) * 0.5f + (rs) * (rs) * 0.5f))

#define NPPClamp(x,min,max)			((x) < (min) ? (min) : ((x) > (max) ? (max) : (x)))
#define NPPClampFull(x,cA,cB)		(NPPClamp(x, MIN(cA, cB), MAX(cA, cB)))

// Times.
#define kNPPAnimTime				0.3f
#define kNPPAnimTimeX2				0.6f

#pragma mark -
#pragma mark Functions Definitions
#pragma mark -
//**********************************************************************************************************
//
//	Functions Definitions
//
//**********************************************************************************************************

/*!
 *					Safely frees a C memory pointer.
 *
 *					Prevents NULL pointers or non-allocated values of being freed (zombies).
 *
 *	@param			x
 *					Any C pointer.
 */
#define nppFree(x)					({ if((x) != NULL) { free((x)); (x) = NULL; } })

/*!
 *					Safely sends a CFRelease message to an Obj-C pointer.
 *
 *	@param			x
 *					Any Core Foundation instance.
 */
#define nppCFRelease(x)				({ if((x) != NULL) { CFRelease((x)); (x) = NULL; } })

/*!
 *					Safely releases an Objective-C instance. ARC friendly.
 *
 *					Prevents nil pointers or non-allocated objects of being released (zombies).
 *
 *	@param			x
 *					Any Obj-C object.
 */
#ifdef NPP_ARC
	#define nppRelease(x)			({ (x) = nil; })
#else
	#define nppRelease(x)			({ if((x) != nil) { [(x) release]; (x) = nil; } })
#endif

/*!
 *					Autoreleases an Objective-C instance. ARC friendly.
 *
 *	@param			x
 *					Any Obj-C object.
 */
#ifdef NPP_ARC
	#define nppAutorelease(x)		(x)
#else
	#define nppAutorelease(x)		([(x) autorelease])
#endif

/*!
 *					Retains an Objective-C instance. ARC friendly.
 *
 *	@param			x
 *					Any Obj-C object.
 */
#ifdef NPP_ARC
	#define nppRetain(x)			(x)
#else
	#define nppRetain(x)			([(x) retain])
#endif

/*!
 *					Safe way to call a block, avoiding nil or invalid instance. This function doesn't
 *					make a copy of the block, it just executes it safely.
 *
 *	@param			block
 *					The block to try the exectution.
 *
 *	@param			...
 *					The possible arguments to the block.
 */
#define nppBlock(block, ...)		({ if ((block) != nil) { (block)(__VA_ARGS__); } })

/*!
 *					Safe way to call a block on the main thread, avoiding nil or invalid instance.
 *					This will dispatch the block asynchronously.
 *
 *	@param			block
 *					The block to try the exectution.
 */
#define nppBlockMain(block, ...)	({ if ((block) != nil) \
{ \
	dispatch_async(dispatch_get_main_queue(), ^(void){ (block)(__VA_ARGS__); }); \
} })

/*!
 *					Safe way to call a block on the main thread, avoiding nil or invalid instance.
 *					This will dispatch the block asynchronously.
 *
 *	@param			block
 *					The block to try the exectution.
 */
#define nppBlockBG(block, ...)			({ if ((block) != nil) \
{ \
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0); \
	dispatch_async(queue, ^(void){ (block)(__VA_ARGS__); }); \
} })

/*!
 *					Safe way to call a block on the main thread, avoiding nil or invalid instance.
 *					Dispatch a block after a delayed time. The dispatch occurs on the current queue.
 *
 *	@param			n
 *					The number of seconds to delay.
 *
 *	@param			block
 *					The block to try the exectution.
 */
#define nppBlockAfter(n, block, ...)	({ if ((block) != nil) \
{ \
	double delayInSeconds = (n); \
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); \
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){ (block)(__VA_ARGS__); }); \
} })
//dispatch_get_current_queue

/*!
 *					This is a simple function that returns the current absolute time of the system.
 *					It is given in seconds (32 bits float data type) and its related to the number of
 *					clock cycles since the start of the system.
 */
#define nppAbsoluteTime()			(CACurrentMediaTime())

/*!
 *					This is a simple macro that defines the a singleton interface.
 *
 *					To create a singleton just use it inside the @interface
 *					instruction passing the classname to it. For example:
 *
 *					@implementation NPPClassA
 *
 *					NPP_SINGLETON_INTERFACE(NPPClassA);
 *					...
 *
 *					@end
 */
#define NPP_SINGLETON_INTERFACE(classname) \
+ (classname *) instance;

/*!
 *					This is a simple macro that defines the a singleton class. ARC friendly.
 *
 *					To create a singleton just use it inside the @implementation
 *					instruction passing the classname to it. For example:
 *
 *					@implementation NPPClassA
 *
 *					NPP_SINGLETON_IMPLEMENTATION(NPPClassA);
 *					...
 *
 *					@end
 */
#ifdef NPP_ARC
	#define NPP_SINGLETON_IMPLEMENTATION(classname) \
	\
	+ (classname *) instance \
	{ \
		static classname *_default = nil; \
		\
		static dispatch_once_t onceToken; \
		dispatch_once(&onceToken, ^{ _default = [[self alloc] init]; }); \
		return _default; \
	}
#else
	#define NPP_SINGLETON_IMPLEMENTATION(classname) \
	\
	+ (classname *) instance \
	{ \
		static classname *_default = nil; \
		\
		static dispatch_once_t safer; \
		dispatch_once(&safer, ^{ _default = [[self alloc] init]; }); \
		return _default; \
	} \
	\
	- (id) copyWithZone:(NSZone *)zone \
	{ \
		return self; \
	} \
	\
	- (id) retain \
	{ \
		return self; \
	} \
	\
	- (oneway void) release \
	{ \
	} \
	\
	- (id) autorelease \
	{ \
		return self; \
	} \
	\
	- (NSUInteger) retainCount \
	{ \
		return NSUIntegerMax; \
	}
#endif

/*!
 *					Generate a static point of access to a Obj-C object. Calling the function will always
 *					return an initialized object.
 *
 *	@param			class
 *					The data type. Must be an Obj-C class, use only the class (e.g. NSMutableArray).
 *
 *	@param			getter
 *					The getter's name.
 */
#define NPP_STATIC_READONLY(class, getter) \
static class *getter(void) \
{ \
	static class *_default = nil; \
	\
	static dispatch_once_t onceToken; \
	dispatch_once(&onceToken, ^(void) \
	{ \
		_default = [[class alloc] init]; \
	}); \
	\
	return _default; \
}

/*!
 *					Generates a property into a category. The property is automatically retained, copied
 *					and released accordingly to its association type.
 *
 *					Example:
 *					<pre>
 *						NPP_CATEGORY_PROPERTY(OBJC_ASSOCIATION_ASSIGN, NSString, foo, setFoo);
 *					</pre>
 *
 *	@param			class
 *					The data type. Must be an Obj-C class, use only the class (e.g. NSMutableArray).
 *
 *	@param			getter
 *					The getter's name.
 *
 *	@param			setter
 *					The setter's name.
 *
 *	@param			assoc
 *					The association type. It can be one of the 5 following options:
 *
 *						- OBJC_ASSOCIATION_ASSIGN: Simple assign.
 *						- OBJC_ASSOCIATION_RETAIN_NONATOMIC: Nonatomic retain, it recives a release
 *							message on deallocation.
 *						- OBJC_ASSOCIATION_COPY_NONATOMIC: Nonatomic copy, it recives a release message
 *							on deallocation.
 *						- OBJC_ASSOCIATION_RETAIN: Atomic retain, it recives a release
 *							message on deallocation.
 *						- OBJC_ASSOCIATION_COPY: Atomic copy, it recives a release message
 *							on deallocation.
 */
#define NPP_CATEGORY_PROPERTY(class, getter, setter, assoc) \
static char k##getter; \
- (class *) getter { return objc_getAssociatedObject(self, &k##getter); } \
- (void) setter:(class *)value \
{ \
	objc_setAssociatedObject(self, &k##getter, value, assoc); \
}

/*!
 *					Generates an auto-initialized persistent readonly property into a category. This
 *					method generates a strong association that will be released only on deallocation.
 *
 *					Example:
 *					<pre>
 *						NPP_CATEGORY_PROPERTY(OBJC_ASSOCIATION_ASSIGN, NSMutableArray, foo);
 *					</pre>
 *
 *	@param			class
 *					The data type. Must be an Obj-C class, use only the class (e.g. NSMutableArray).
 *
 *	@param			getter
 *					The getter's name.
 */
#define NPP_CATEGORY_PROPERTY_READONLY(class, getter) \
static char k##getter; \
- (class *) getter \
{ \
	class *object = objc_getAssociatedObject(self, &k##getter); \
	\
	if (object == nil) \
	{ \
		object = nppAutorelease([[class alloc] init]); \
		objc_setAssociatedObject(self, &k##getter, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
	} \
	\
	return object; \
}