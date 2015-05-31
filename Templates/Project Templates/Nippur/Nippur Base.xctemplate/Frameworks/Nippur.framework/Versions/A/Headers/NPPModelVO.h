/*
 *	NPPModelVO.h
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

#import "NPPRuntime.h"
#import "NPPJSON.h"
#import "NPPDataManager.h"

/*!
 *					The base model class for MVC format. This abstract model defines very important and
 *					key methods for saving and loading models directly to binary files with the secure
 *					framework encription.
 *
 *					Besides, this class can work with JSON formats for server side inputs and outputs.
 */
@interface NPPModelVO : NSObject <NPPJSONSource, NSCoding, NSCopying>

/*!
 *					Creates a new model using the same format as dataForJSON. This method will
 *					make a call to #updateWithData:#
 *
 *	@param			data
 *					The data in a format that is acceptable by this model.
 *
 *	@result			An instance of this model.
 *
 *	@see			updateWithData:
 */
- (id) initWithData:(id)data;

/*!
 *					Creates a new model using the same format as dataForJSON. This method will
 *					make a call to #updateWithData:#
 *
 *	@param			data
 *					The data in a format that is acceptable by this model.
 *
 *	@result			An autoreleased instance of this model.
 *
 *	@see			updateWithData:
 */
+ (id) modelWithData:(id)data;

/*!
 *					Creates a new model using a local file priviously saved using the
 *					#saveToFile:folder:# method.
 *
 *	@result			An autoreleased instance of this model.
 *
 *	@see			saveToFile:folder:
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
 *	@see			NPPJSONSource::dataForJSON
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