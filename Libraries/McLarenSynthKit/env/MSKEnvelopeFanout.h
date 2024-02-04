/** -*- mode:objc -*-
 *
 * An Envelope Fanout re-sends the envelope protocol methods (noteOff, noteAbort
 * and noteReset) to a collection of envelopes. 
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import "McLarenSynthKit/MSKContext.h"

@interface MSKEnvelopeFanout : MSKContextEnvelope

@property (readwrite) MSKContextEnvelope *env1;
@property (readwrite) MSKContextEnvelope *env2;
@property (readwrite) MSKContextEnvelope *env3;
@property (readwrite) MSKContextEnvelope *env4;

- (id) initWithCtx:(MSKContext*)c;
- (BOOL) noteOff;
- (BOOL) noteAbort;
- (BOOL) noteReset:(int)idx;

@end
