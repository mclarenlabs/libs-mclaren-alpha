/** -*- mode:objc -*-
 *
 * ObjC wrapper for Freeverb algorithm.
 *
 *
 * Original 
 *  Written by Jezar at Dreampoint, June 2000
 *  http://www.dreampoint.co.uk
 *  This code is public domain
 *
 * Copyright (c) McLaren Labs 2024
 */

#import "McLarenSynthKit/MSKContext.h"
#import "McLarenSynthKit/model/MSKReverbModel.h"

@interface MSKFreeverbReverb : MSKContextVoice
- (id) initWithCtx:(MSKContext*)c;
- (void) mute;
	     
// property: input
@property (nonatomic, readwrite) MSKContextVoice *sInput;
		     
// the model
@property (nonatomic, readwrite) MSKReverbModel *model;


@end

