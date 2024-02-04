/** -*- mode:objc -*-
 *
 * Generalized Filter with input sInput and configuration properties.
 *
 * Biquad Ref: http://www.earlevel.com/main/2012/11/26/biquad-c-source-code/
 * Moog Ref: Will Pirkle
 *
 * Note: Modified to take Fc in units of Hz.
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/model/MSKFilterModel.h"

@interface MSKGeneralFilter : MSKContextVoice

// property: input
@property (nonatomic, readwrite) MSKContextVoice *sInput;

// the model
@property (nonatomic, readwrite) MSKFilterModel *model;

- (id) initWithCtx:(MSKContext*)c;

+ (MSKGeneralFilter*) filterWithLowpass:(MSKContext*)ctx; // pre-made LPF filter

@end

