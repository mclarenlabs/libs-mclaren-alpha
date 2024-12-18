/** -*- mode: objc -*-
 *
 * Controller for MSKDrawbarModel
 *
 */

#import <AppKit/AppKit.h>
#import "McLarenSynthKit/model/MSKDrawbarModel.h"
#import "MLVerticalSliderWithValue.h"

@interface MLDrawbarController : NSBox

@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v0;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v1;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v2;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v3;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v4;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v5;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v6;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v7;
@property (nonatomic, retain, strong) MLVerticalSliderWithValue *v8;

- (void) bindToModel:(MSKDrawbarModel*)model;

@end
