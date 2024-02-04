/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2; -*-
 *
 * An envelope produces a buffer of values in [0 .. 1.0]
 *
 * This envelope linearly transitions from point to point.
 * 
 * Copyright (c) McLaren Labs 2024
 *
 */

#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/model/MSKEnvelopeModel.h"

@interface MSKLinEnvelope : MSKContextEnvelope

@property (nonatomic, readwrite) BOOL oneshot; 
@property (nonatomic, readwrite) double shottime;

// the initial Gain
@property (nonatomic, readwrite) double iGain;

// the model
@property (nonatomic, readwrite) MSKEnvelopeModel *model;

- (id) initWithCtx:(MSKContext*)c;

@end
