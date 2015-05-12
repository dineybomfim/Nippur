/*
 *	NPPPickerView.h
 *	Nippur
 *	v1.0
 *	
 *	Created by Diney Bomfim on 02/27/12.
 *	Copyright 2012 db-in. All rights reserved.
 */

#import "NippurCore.h"
#import "NippurAnimation.h"

#import "NPPView+UIView.h"
#import "NPPWindowKeyboard.h"

@interface NPPPickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>

+ (void) setPickerDelegate:(id <UIPickerViewDelegate>)target;

+ (void) setDataFromDict:(NSDictionary *)dict sortData:(BOOL)sorting;
+ (void) setDataFromFile:(NSString *)fileNamed sortData:(BOOL)sorting;

+ (NSString *) selectedTextAtColumn:(NSUInteger)column;
+ (NSInteger) selectedRowAtColumn:(NSUInteger)column;

+ (void) selectText:(NSString *)text atColumn:(NSUInteger)column;
+ (void) selectRow:(NSUInteger)row atColumn:(NSUInteger)column;

+ (void) showPickerView;
+ (void) hidePickerView;
+ (void) movePickerViewToY:(float)toY;

+ (NPPPickerView *) instance;

@end

@interface NPPDataManager(NPPPickerData)

+ (NSDictionary *) pickerDataWithArray:(NSArray *)array;

@end