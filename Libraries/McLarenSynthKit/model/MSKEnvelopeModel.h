/** -*- mode:objc; indent-tabs-mode:nil; tab-width:2;  -*-
 *
 * Model for Envelopes
 *
 * Copyright (c) McLaren Labs 2024
 *
 */

#import <Foundation/Foundation.h>

/*
 * An Envelope Model holds parameters that envelope generators use.
 */

@interface MSKEnvelopeModel : NSObject {
@public
  double _attack;
  double _decay;
  double _sustain;
  double _rel;
  double _sens;
}

// the properties of the model
@property (nonatomic, readwrite) double attack;
@property (nonatomic, readwrite) double decay;
@property (nonatomic, readwrite) double sustain;
@property (nonatomic, readwrite) double rel; // 'release' is a reserved word
@property (nonatomic, readwrite) double sens; // sensitivity of gain to velocity

- (id) init;

// utility: compute envelope iGain [0..1.0] as a function of note velocity [0..127] and sens
- (double) iGainForVel:(uint8_t)vel;

@end
