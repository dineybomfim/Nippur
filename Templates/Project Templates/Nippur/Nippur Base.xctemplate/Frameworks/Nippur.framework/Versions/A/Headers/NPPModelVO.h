/*
 *	NPPModelVO.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 4/6/13.
 *	Copyright 2013 db-in. All rights reserved.
 */

#import "NPPRuntime.h"
#import "NPPJSON.h"
#import "NPPDataManager.h"

@interface NPPModelVO : NSObject <NPPJSONSource, NSCoding, NSCopying>

/*!
 *					Creates a new model using the same format as dataForJSON. This method will
 *					make a call to #updateWithData:#
 *
 *	@see			updateWithData:
 *
 *	@result			An instance of this model.
 */
- (id) initWithData:(id)data;

/*!
 *					Creates a new model using the same format as dataForJSON. This method will
 *					make a call to #updateWithData:#
 *
 *	@see			updateWithData:
 *
 *	@result			An autoreleased instance of this model.
 */
+ (id) modelWithData:(id)data;

/*!
 *					Creates a new model using a local file priviously saved using the
 *					#saveToFile:folder:# method.
 *
 *	@see			saveToFile:folder:
 *
 *	@result			An autoreleased instance of this model.
 */
+ (id) modelFromFile:(NSString *)fileName folder:(NPPDataFolder)folder;

/*!
 *					Updates this object using the same data structure used for JSON. It must be in the same
 *					format as the output of #dataForJSON#.
 *
 *					Passing nil as parameter to this method will resets this object to its initial state.
 *
 *					Each subclass must give its own implementation for this method.
 *
 *	@param			data
 *					It can be NSString, NSNumber, NSArray or NSDictionary.
 *
 *	@see			dataForJSON
 */
- (void) updateWithData:(id)data;

/*!
 *					Checks for compatibility with data when using the #updateWithData:# method.
 *					As best practice, always call this method right in front when overriding the
 *					#updateWithData:# method, passing a class to check compatibility.
 *
 *					This method return the result for compatibility and changes the data pointer if
 *					it's necessary.
 *
 *	@param			dataPointer
 *					A pointer to incoming data. The data it self can be changed if necessary.
 *
 *	@param			aClass
 *					A class pointer to check compatibility.
 *
 *	@result			A boolean indicating if there is a valid compatibility.
 */
- (BOOL) checkCompatibility:(id *)dataPointer checkClass:(Class)aClass;

/*!
 *					This method writes down this model to a local folder using a super fast binary
 *					encoding, the internal binary format follows the exactly same structure as define by
 *					#dataForJSON#, so the model must be already implementing it.
 *
 *	@param			fileName
 *					The local file's name.
 *
 *	@param			folder
 *					The local folder, using Nippur path API.
 */
- (void) saveToFile:(NSString *)fileName folder:(NPPDataFolder)folder;

/*!
 *					Updates this object using a local file which was previously saved using
 *					the #saveToFile:folder:# method.
 *
 *	@param			fileName
 *					The local file's name.
 *
 *	@param			folder
 *					The local folder, using Nippur path API.
 *
 *	@see			saveToFile:folder:
 */
- (void) loadFromFile:(NSString *)fileName folder:(NPPDataFolder)folder;

@end